import { createContext, useCallback, useContext, useState, type ReactNode } from 'react';
import { CheckCircle, XCircle, AlertCircle, X } from 'lucide-react';

type ToastType = 'success' | 'error' | 'info';

interface ToastItem {
  id: string;
  type: ToastType;
  message: string;
}

interface ToastContextType {
  toast: (type: ToastType, message: string) => void;
}

const ToastContext = createContext<ToastContextType>({ toast: () => {} });

export function useToast() {
  return useContext(ToastContext);
}

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<ToastItem[]>([]);

  const toast = useCallback((type: ToastType, message: string) => {
    const id = crypto.randomUUID();
    setToasts((prev) => [...prev, { id, type, message }]);
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 4000);
  }, []);

  const dismiss = useCallback((id: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  }, []);

  const icons: Record<ToastType, typeof CheckCircle> = {
    success: CheckCircle, error: XCircle, info: AlertCircle,
  };

  const colors: Record<ToastType, string> = {
    success: 'border-buddy-green bg-buddy-green/10',
    error: 'border-buddy-red bg-buddy-red/10',
    info: 'border-buddy-electric bg-buddy-electric/10',
  };

  const iconColors: Record<ToastType, string> = {
    success: 'text-buddy-green', error: 'text-buddy-red', info: 'text-buddy-electric',
  };

  return (
    <ToastContext.Provider value={{ toast }}>
      {children}
      <div className="fixed top-4 left-1/2 -translate-x-1/2 z-[100] flex flex-col gap-2">
        {toasts.map((t) => {
          const Icon = icons[t.type];
          return (
            <div key={t.id} className={`flex items-center gap-3 px-4 py-3 rounded-xl border shadow-lg ${colors[t.type]}`}>
              <Icon size={18} className={iconColors[t.type]} />
              <span className="text-sm text-buddy-text-primary">{t.message}</span>
              <button onClick={() => dismiss(t.id)} className="ml-2 text-buddy-text-secondary hover:text-buddy-text-primary">
                <X size={14} />
              </button>
            </div>
          );
        })}
      </div>
    </ToastContext.Provider>
  );
}
