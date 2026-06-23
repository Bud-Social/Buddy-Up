import { ReactNode, useEffect } from 'react';
import { X } from 'lucide-react';
interface ModalProps { isOpen: boolean; onClose: () => void; title?: string; children: ReactNode; size?: 'sm' | 'md' | 'lg'; className?: string; }
const sz: Record<string, string> = { sm: 'max-w-sm', md: 'max-w-md', lg: 'max-w-lg' };
export function Modal({ isOpen, onClose, title, children, size = 'md', className }: ModalProps) {
  useEffect(() => { if (isOpen) document.body.style.overflow = 'hidden'; else document.body.style.overflow = ''; return () => { document.body.style.overflow = ''; }; }, [isOpen]);
  useEffect(() => { const h = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); }; if (isOpen) window.addEventListener('keydown', h); return () => window.removeEventListener('keydown', h); }, [isOpen, onClose]);
  if (!isOpen) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="fixed inset-0 bg-black/70 backdrop-blur-sm" onClick={onClose} />
      <div className={`relative bg-buddy-surface-raised rounded-2xl w-full p-6 shadow-2xl ${sz[size]} ${className || ''}`}>
        {title && <div className="flex items-center justify-between mb-4"><h2 className="text-lg font-heading font-semibold">{title}</h2><button onClick={onClose} className="p-1 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary"><X size={20} /></button></div>}
        {children}
      </div>
    </div>
  );
}
