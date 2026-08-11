import { useState, useEffect } from 'react';

export type DeviceType = 'mobile' | 'tablet' | 'desktop';
export type DeviceOs = 'android' | 'ios' | 'other';

function detectOs(): DeviceOs {
  const ua = navigator.userAgent || navigator.vendor || '';
  if (/android/i.test(ua)) return 'android';
  if (/iPad|iPhone|iPod|Macintosh/i.test(ua) && navigator.maxTouchPoints > 1) return 'ios';
  return 'other';
}

export function useDeviceType(): { type: DeviceType; os: DeviceOs; isMobile: boolean; isTablet: boolean; isDesktop: boolean } {
  const [type, setType] = useState<DeviceType>('desktop');
  const [os, setOs] = useState<DeviceOs>('other');

  useEffect(() => {
    const update = () => {
      const width = window.innerWidth;
      let t: DeviceType = 'desktop';
      if (width >= 768 && width <= 1024) t = 'tablet';
      else if (width < 768) t = 'mobile';
      setType(t);
    };
    update();
    setOs(detectOs());
    window.addEventListener('resize', update);
    return () => window.removeEventListener('resize', update);
  }, []);

  return {
    type,
    os,
    isMobile: type === 'mobile',
    isTablet: type === 'tablet',
    isDesktop: type === 'desktop',
  };
}
