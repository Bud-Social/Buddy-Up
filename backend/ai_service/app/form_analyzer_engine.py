import logging
import math
import os
import tempfile
from collections import Counter

import numpy as np

from app.config import settings

logger = logging.getLogger(__name__)

MEDIAPIPE_AVAILABLE = False
mp = None
mp_pose = None
mp_drawing = None

if settings.enable_mediapipe:
    try:
        import mediapipe as mp
        mp_pose = mp.solutions.pose
        mp_drawing = mp.solutions.drawing_utils
        MEDIAPIPE_AVAILABLE = True
    except (ImportError, AttributeError):
        logger.warning('MediaPipe legacy API unavailable. Form analysis will be degraded.')
else:
    logger.info('MediaPipe disabled (config.enable_mediapipe=False); keeping torch/HF stable.')

try:
    import cv2
    CV2_AVAILABLE = True
except ImportError:
    cv2 = None
    CV2_AVAILABLE = False


def _angle_between(v1: np.ndarray, v2: np.ndarray) -> float:
    unit_v1 = v1 / np.linalg.norm(v1)
    unit_v2 = v2 / np.linalg.norm(v2)
    dot = np.clip(np.dot(unit_v1, unit_v2), -1.0, 1.0)
    return math.degrees(np.arccos(dot))


def _calculate_joint_angle(
    landmarks: np.ndarray,
    p1_idx: int,
    p2_idx: int,
    p3_idx: int,
) -> float:
    p1 = np.array([landmarks[p1_idx].x, landmarks[p1_idx].y])
    p2 = np.array([landmarks[p2_idx].x, landmarks[p2_idx].y])
    p3 = np.array([landmarks[p3_idx].x, landmarks[p3_idx].y])
    v1 = p1 - p2
    v2 = p3 - p2
    return _angle_between(v1, v2)


def _analyze_squat(landmarks: np.ndarray) -> dict:
    feedback = []
    issues = []

    hip_angle = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.SHOULDER, mp_pose.PoseLandmark.HIP, mp_pose.PoseLandmark.KNEE)
    knee_angle = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.HIP, mp_pose.PoseLandmark.KNEE, mp_pose.PoseLandmark.ANKLE)
    
    left_shoulder_y = landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].y
    right_shoulder_y = landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER].y
    shoulder_diff = abs(left_shoulder_y - right_shoulder_y)

    if hip_angle < 80:
        feedback.append('Good depth!')
    elif hip_angle < 90:
        feedback.append('Try to squat deeper for full range of motion.')
    else:
        feedback.append('Squat deeper - aim for hips below parallel.')
        issues.append('shallow_squat')

    if 70 <= knee_angle <= 110:
        feedback.append('Good knee flexion.')
    elif knee_angle > 120:
        feedback.append('Bend your knees more.')
        issues.append('insufficient_knee_bend')

    if shoulder_diff > 0.05:
        feedback.append('Keep your shoulders level.')
        issues.append('uneven_shoulders')

    score = max(0, 100 - len(issues) * 25)
    return {
        'exercise': 'squat',
        'form_score': score,
        'hip_angle': round(hip_angle, 1),
        'knee_angle': round(knee_angle, 1),
        'feedback': feedback,
        'issues': issues,
    }


def _analyze_deadlift(landmarks: np.ndarray) -> dict:
    feedback = []
    issues = []

    back_angle = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.HIP, mp_pose.PoseLandmark.SHOULDER, mp_pose.PoseLandmark.EAR)
    hip_angle = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.SHOULDER, mp_pose.PoseLandmark.HIP, mp_pose.PoseLandmark.KNEE)
    
    left_hip_y = landmarks[mp_pose.PoseLandmark.LEFT_HIP].y
    right_hip_y = landmarks[mp_pose.PoseLandmark.RIGHT_HIP].y
    hip_diff = abs(left_hip_y - right_hip_y)

    if back_angle > 160:
        feedback.append('Good - keep your back straight.')
    else:
        feedback.append('Keep your back straighter - avoid rounding.')
        issues.append('rounded_back')

    if hip_angle < 100:
        feedback.append('Lower your hips for proper setup.')
        issues.append('hips_too_high')
    elif hip_angle > 140:
        feedback.append('Hips might be too low.')
        issues.append('hips_too_low')

    if hip_diff > 0.05:
        feedback.append('Keep hips level.')
        issues.append('uneven_hips')

    score = max(0, 100 - len(issues) * 25)
    return {
        'exercise': 'deadlift',
        'form_score': score,
        'back_angle': round(back_angle, 1),
        'hip_angle': round(hip_angle, 1),
        'feedback': feedback,
        'issues': issues,
    }


def _analyze_bench_press(landmarks: np.ndarray) -> dict:
    feedback = []
    issues = []

    left_elbow_angle = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.LEFT_SHOULDER, mp_pose.PoseLandmark.LEFT_ELBOW, mp_pose.PoseLandmark.LEFT_WRIST)
    right_elbow_angle = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.RIGHT_SHOULDER, mp_pose.PoseLandmark.RIGHT_ELBOW, mp_pose.PoseLandmark.RIGHT_WRIST)

    avg_elbow = (left_elbow_angle + right_elbow_angle) / 2

    if 70 <= avg_elbow <= 100:
        feedback.append('Good elbow position at bottom.')
    elif avg_elbow > 110:
        feedback.append('Tuck your elbows more - avoid flaring.')
        issues.append('elbow_flare')
    else:
        feedback.append('Elbows might be too tucked.')
        issues.append('elbows_too_tucked')

    left_shoulder_y = landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].y
    right_shoulder_y = landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER].y
    shoulder_diff = abs(left_shoulder_y - right_shoulder_y)
    if shoulder_diff > 0.05:
        feedback.append('Keep shoulders level on the bench.')
        issues.append('uneven_shoulders')

    score = max(0, 100 - len(issues) * 25)
    return {
        'exercise': 'bench_press',
        'form_score': score,
        'left_elbow_angle': round(left_elbow_angle, 1),
        'right_elbow_angle': round(right_elbow_angle, 1),
        'feedback': feedback,
        'issues': issues,
    }


def _analyze_overhead_press(landmarks: np.ndarray) -> dict:
    feedback = []
    issues = []

    left_elbow_angle = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.LEFT_SHOULDER, mp_pose.PoseLandmark.LEFT_ELBOW, mp_pose.PoseLandmark.LEFT_WRIST)
    right_elbow_angle = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.RIGHT_SHOULDER, mp_pose.PoseLandmark.RIGHT_ELBOW, mp_pose.PoseLandmark.RIGHT_WRIST)

    avg_elbow = (left_elbow_angle + right_elbow_angle) / 2

    if avg_elbow < 170:
        feedback.append('Fully extend your arms at the top.')
        issues.append('incomplete_lockout')
    else:
        feedback.append('Good lockout at the top.')

    left_hip_y = landmarks[mp_pose.PoseLandmark.LEFT_HIP].y
    right_hip_y = landmarks[mp_pose.PoseLandmark.RIGHT_HIP].y
    hip_diff = abs(left_hip_y - right_hip_y)
    if hip_diff > 0.05:
        feedback.append('Keep your core tight and hips level.')
        issues.append('hip_hike')

    score = max(0, 100 - len(issues) * 25)
    return {
        'exercise': 'overhead_press',
        'form_score': score,
        'left_elbow_angle': round(left_elbow_angle, 1),
        'right_elbow_angle': round(right_elbow_angle, 1),
        'feedback': feedback,
        'issues': issues,
    }


def _analyze_bicep_curl(landmarks: np.ndarray) -> dict:
    feedback = []
    issues = []

    left_elbow = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.LEFT_SHOULDER, mp_pose.PoseLandmark.LEFT_ELBOW, mp_pose.PoseLandmark.LEFT_WRIST)
    right_elbow = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.RIGHT_SHOULDER, mp_pose.PoseLandmark.RIGHT_ELBOW, mp_pose.PoseLandmark.RIGHT_WRIST)
    avg_elbow = (left_elbow + right_elbow) / 2

    if avg_elbow <= 70:
        feedback.append('Good — full bicep contraction at the top.')
    elif avg_elbow <= 100:
        feedback.append('Squeeze the weight higher for a full contraction.')
        issues.append('partial_rep')
    else:
        feedback.append('Your elbows are barely bending — complete the curl.')
        issues.append('incomplete_curl')

    left_shoulder_y = landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].y
    right_shoulder_y = landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER].y
    if abs(left_shoulder_y - right_shoulder_y) > 0.05:
        feedback.append('Keep your elbows tucked — avoid swinging the weight.')
        issues.append('elbow_swing')

    score = max(0, 100 - len(issues) * 25)
    return {
        'exercise': 'bicep_curl',
        'form_score': score,
        'left_elbow_angle': round(left_elbow, 1),
        'right_elbow_angle': round(right_elbow, 1),
        'feedback': feedback,
        'issues': issues,
    }


def _analyze_push_up(landmarks: np.ndarray) -> dict:
    feedback = []
    issues = []

    left_elbow = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.LEFT_SHOULDER, mp_pose.PoseLandmark.LEFT_ELBOW, mp_pose.PoseLandmark.LEFT_WRIST)
    right_elbow = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.RIGHT_SHOULDER, mp_pose.PoseLandmark.RIGHT_ELBOW, mp_pose.PoseLandmark.RIGHT_WRIST)
    avg_elbow = (left_elbow + right_elbow) / 2

    back_angle = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.HIP, mp_pose.PoseLandmark.SHOULDER, mp_pose.PoseLandmark.EAR)

    if avg_elbow <= 110:
        feedback.append('Good depth at the bottom.')
    else:
        feedback.append('Lower your chest closer to the ground.')
        issues.append('insufficient_depth')

    if back_angle > 155:
        feedback.append('Good — body stays in a straight line.')
    else:
        feedback.append('Keep your hips from sagging — brace your core.')
        issues.append('hip_sag')

    hip_diff = abs(landmarks[mp_pose.PoseLandmark.LEFT_HIP].y - landmarks[mp_pose.PoseLandmark.RIGHT_HIP].y)
    if hip_diff > 0.05:
        feedback.append('Keep hips level.')
        issues.append('uneven_hips')

    score = max(0, 100 - len(issues) * 25)
    return {
        'exercise': 'push_up',
        'form_score': score,
        'elbow_angle': round(avg_elbow, 1),
        'back_angle': round(back_angle, 1),
        'feedback': feedback,
        'issues': issues,
    }


def _analyze_plank(landmarks: np.ndarray) -> dict:
    feedback = []
    issues = []

    back_angle = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.SHOULDER, mp_pose.PoseLandmark.HIP, mp_pose.PoseLandmark.ANKLE)

    if back_angle > 155:
        feedback.append('Good — body in a straight line.')
    elif back_angle > 140:
        feedback.append('Your hips are sagging — tighten your core and glutes.')
        issues.append('hips_dropped')
    else:
        feedback.append('Your hips are too high or low — align head, back, and heels.')
        issues.append('broken_plank')

    hip_diff = abs(landmarks[mp_pose.PoseLandmark.LEFT_HIP].y - landmarks[mp_pose.PoseLandmark.RIGHT_HIP].y)
    if hip_diff > 0.05:
        feedback.append('Keep hips level side-to-side.')
        issues.append('uneven_hips')

    score = max(0, 100 - len(issues) * 25)
    return {
        'exercise': 'plank',
        'form_score': score,
        'back_angle': round(back_angle, 1),
        'feedback': feedback,
        'issues': issues,
    }


def _analyze_lunge(landmarks: np.ndarray) -> dict:
    feedback = []
    issues = []

    left_knee = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.LEFT_HIP, mp_pose.PoseLandmark.LEFT_KNEE, mp_pose.PoseLandmark.LEFT_ANKLE)
    right_knee = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.RIGHT_HIP, mp_pose.PoseLandmark.RIGHT_KNEE, mp_pose.PoseLandmark.RIGHT_ANKLE)
    front_knee = min(left_knee, right_knee)

    torso_angle = _calculate_joint_angle(landmarks, mp_pose.PoseLandmark.HIP, mp_pose.PoseLandmark.SHOULDER, mp_pose.PoseLandmark.EAR)

    if 70 <= front_knee <= 110:
        feedback.append('Good — front knee bent to ~90 degrees.')
    elif front_knee < 70:
        feedback.append('Your front knee is tracking too far forward — keep it over the ankle.')
        issues.append('knee_past_toe')
    else:
        feedback.append('Bend your front knee deeper for a fuller lunge.')
        issues.append('shallow_lunge')

    if torso_angle < 125:
        feedback.append('Keep your torso upright.')
        issues.append('torso_lean')

    score = max(0, 100 - len(issues) * 25)
    return {
        'exercise': 'lunge',
        'form_score': score,
        'front_knee_angle': round(front_knee, 1),
        'torso_angle': round(torso_angle, 1),
        'feedback': feedback,
        'issues': issues,
    }


def _analyze_frame(frame_bgr: np.ndarray, exercise: str) -> dict | None:
    """Run pose detection + form analysis on a single BGR frame. None if no pose."""
    if not MEDIAPIPE_AVAILABLE or not CV2_AVAILABLE:
        return None

    frame_rgb = cv2.cvtColor(frame_bgr, cv2.COLOR_BGR2RGB)
    mp_pose_instance = mp_pose.Pose(static_image_mode=True, min_detection_confidence=0.5, min_tracking_confidence=0.5)
    try:
        result = mp_pose_instance.process(frame_rgb)
        if not result.pose_landmarks:
            return None

        landmarks_np = np.array(result.pose_landmarks.landmark)
        if exercise == 'auto':
            exercise = _detect_exercise(landmarks_np)

        analyzers = {
            'squat': _analyze_squat,
            'deadlift': _analyze_deadlift,
            'bench_press': _analyze_bench_press,
            'overhead_press': _analyze_overhead_press,
            'bicep_curl': _analyze_bicep_curl,
            'push_up': _analyze_push_up,
            'plank': _analyze_plank,
            'lunge': _analyze_lunge,
        }

        analyzer = analyzers.get(exercise)
        if analyzer:
            return analyzer(landmarks_np)
        return {
            'exercise': exercise,
            'form_score': 50,
            'feedback': [f'{exercise.replace("_", " ").title()} analysis coming soon.'],
            'issues': [],
        }
    finally:
        mp_pose_instance.close()


def analyze_form(image_bytes: bytes, exercise: str = 'auto') -> dict:
    if not MEDIAPIPE_AVAILABLE:
        return {'error': 'MediaPipe not available', 'form_score': 0, 'feedback': ['Form analysis unavailable.']}

    try:
        nparr = np.frombuffer(image_bytes, np.uint8)
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        if frame is None:
            return {'error': 'Invalid image', 'form_score': 0, 'feedback': ['Could not decode image.']}
    except Exception as e:  # noqa: BLE001
        logger.error('Image decode error: %s', e)
        return {'error': 'Image processing failed', 'form_score': 0, 'feedback': ['Image processing failed.']}

    result = _analyze_frame(frame, exercise)
    if result is None:
        return {'error': 'No pose detected', 'form_score': 0, 'feedback': ['No body detected in image.']}
    return result


def analyze_form_video(
    video_bytes: bytes,
    exercise: str = 'auto',
    frame_interval: int = 3,
    max_frames: int = 90,
) -> dict:
    """Sample frames from a workout video and aggregate per-frame form scores."""
    if not MEDIAPIPE_AVAILABLE or not CV2_AVAILABLE:
        return {'error': 'MediaPipe not available', 'form_score': 0, 'feedback': ['Form analysis unavailable.']}

    fd, path = tempfile.mkstemp(suffix='.mp4')
    try:
        with os.fdopen(fd, 'wb') as fh:
            fh.write(video_bytes)
        cap = cv2.VideoCapture(path)
        if not cap.isOpened():
            return {'error': 'Invalid video', 'form_score': 0, 'feedback': ['Could not decode video.']}

        frame_scores = []
        detected_exercise = exercise
        idx = 0
        while True:
            ret, frame = cap.read()
            if not ret or len(frame_scores) >= max_frames:
                break
            if idx % frame_interval == 0:
                result = _analyze_frame(frame, exercise)
                if result is not None:
                    if exercise == 'auto':
                        detected_exercise = result.get('exercise', detected_exercise)
                    frame_scores.append({'frame_index': idx, **result})
            idx += 1
        cap.release()
    except Exception as exc:  # noqa: BLE001
        logger.error('Video analysis error: %s', exc)
        return {'error': 'Video processing failed', 'form_score': 0, 'feedback': ['Video processing failed.']}
    finally:
        try:
            os.remove(path)
        except OSError:
            pass

    if not frame_scores:
        return {'error': 'No pose detected', 'form_score': 0, 'feedback': ['No body detected in video.']}

    scores = [f['form_score'] for f in frame_scores]
    avg_score = int(round(sum(scores) / len(scores)))
    best = max(frame_scores, key=lambda f: f['form_score'])
    worst = min(frame_scores, key=lambda f: f['form_score'])

    issue_counts = Counter(i for f in frame_scores for i in f.get('issues', []))
    top_issues = [{'issue': k, 'frames': v} for k, v in issue_counts.most_common(5)]

    feedback_order = []
    for f in frame_scores:
        for msg in f.get('feedback', []):
            if msg not in feedback_order:
                feedback_order.append(msg)
    feedback = feedback_order[:6]

    return {
        'exercise': detected_exercise,
        'video': True,
        'frames_analyzed': len(frame_scores),
        'avg_form_score': avg_score,
        'min_form_score': min(scores),
        'max_form_score': max(scores),
        'best_frame': best['frame_index'],
        'worst_frame': worst['frame_index'],
        'top_issues': top_issues,
        'feedback': feedback,
        'issues': list(issue_counts.keys()),
    }


def _detect_exercise(landmarks: np.ndarray) -> str:
    shoulder_y = (landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].y + landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER].y) / 2
    hip_y = (landmarks[mp_pose.PoseLandmark.LEFT_HIP].y + landmarks[mp_pose.PoseLandmark.RIGHT_HIP].y) / 2
    knee_y = (landmarks[mp_pose.PoseLandmark.LEFT_KNEE].y + landmarks[mp_pose.PoseLandmark.RIGHT_KNEE].y) / 2

    if shoulder_y < hip_y < knee_y:
        return 'overhead_press'
    elif hip_y < shoulder_y and knee_y < hip_y:
        return 'squat'
    elif abs(shoulder_y - hip_y) < 0.1:
        return 'bench_press'
    else:
        return 'deadlift'