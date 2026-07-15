import logging
import math
from typing import Any

import numpy as np

logger = logging.getLogger(__name__)

try:
    import mediapipe as mp
    mp_pose = mp.solutions.pose
    mp_drawing = mp.solutions.drawing_utils
    MEDIAPIPE_AVAILABLE = True
except ImportError:
    MEDIAPIPE_AVAILABLE = False
    logger.warning('MediaPipe not installed. Form analysis will be unavailable.')


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


def analyze_form(image_bytes: bytes, exercise: str = 'auto') -> dict:
    if not MEDIAPIPE_AVAILABLE:
        return {'error': 'MediaPipe not available', 'form_score': 0, 'feedback': ['Form analysis unavailable.']}

    mp_pose_instance = mp_pose.Pose(static_image_mode=True, min_detection_confidence=0.5, min_tracking_confidence=0.5)
    
    try:
        import cv2
        nparr = np.frombuffer(image_bytes, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        if image is None:
            return {'error': 'Invalid image', 'form_score': 0, 'feedback': ['Could not decode image.']}
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    except Exception as e:
        logger.error('Image decode error: %s', e)
        return {'error': 'Image processing failed', 'form_score': 0, 'feedback': ['Image processing failed.']}

    try:
        result = mp_pose_instance.process(image_rgb)
        if not result.pose_landmarks:
            return {'error': 'No pose detected', 'form_score': 0, 'feedback': ['No body detected in image.']}

        landmarks = result.pose_landmarks.landmark
        landmarks_np = np.array(landmarks)

        if exercise == 'auto':
            exercise = _detect_exercise(landmarks)

        analyzers = {
            'squat': _analyze_squat,
            'deadlift': _analyze_deadlift,
            'bench_press': _analyze_bench_press,
            'overhead_press': _analyze_overhead_press,
        }

        analyzer = analyzers.get(exercise)
        if analyzer:
            return analyzer(landmarks_np)
        else:
            return {
                'exercise': exercise,
                'form_score': 50,
                'feedback': [f'{exercise.replace("_", " ").title()} analysis coming soon.'],
                'issues': [],
            }
    finally:
        mp_pose_instance.close()


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