from fastapi import APIRouter, Form, HTTPException

from ..policy_engine import analyze_health_claims, analyze_sponsorship

router = APIRouter()


@router.post('/health-claims')
async def policy_health_claims(text: str = Form(...)):
    """Scope-of-practice check: flag nutrition/fitness text that implies
    diagnosing, treating, curing or managing a medical condition, plus
    guarantee / quick-fix red flags."""
    if not text or not text.strip():
        raise HTTPException(status_code=400, detail='text is required')
    result = analyze_health_claims(text)
    return {
        'has_medical_claim': result['has_medical_claim'],
        'confidence': result['confidence'],
        'matched_terms': result['matched_terms'],
        'risk_level': result['risk_level'],
        'action': result['action'],
        'method': result['method'],
    }


@router.post('/sponsorship')
async def policy_sponsorship(text: str = Form(...)):
    """Material-connection check: flag promotional/gifting content that lacks a
    prominent sponsorship disclosure."""
    if not text or not text.strip():
        raise HTTPException(status_code=400, detail='text is required')
    result = analyze_sponsorship(text)
    return {
        'is_promotional': result['is_promotional'],
        'has_disclosure': result['has_disclosure'],
        'disclosure_compliant': result['disclosure_compliant'],
        'confidence': result['confidence'],
        'matched_terms': result['matched_terms'],
        'weak_disclosure': result.get('weak_disclosure', []),
        'action': result['action'],
        'method': result['method'],
    }
