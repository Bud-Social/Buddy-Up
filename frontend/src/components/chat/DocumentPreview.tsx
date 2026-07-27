import { useState, useEffect } from 'react';
import { X, Download, FileText, File, FileSpreadsheet, FileImage, FileArchive } from 'lucide-react';
import { apiClient } from '@/api/client';

interface DocPreviewProps {
  url: string;
  name: string;
  mime: string;
  onClose: () => void;
}

function fileIcon(mime: string) {
  if (mime.startsWith('image/')) return FileImage;
  if (mime.includes('spreadsheet') || mime.includes('excel') || mime.includes('csv')) return FileSpreadsheet;
  if (mime.includes('pdf')) return FileText;
  if (mime.includes('zip') || mime.includes('rar') || mime.includes('tar') || mime.includes('7z')) return FileArchive;
  return File;
}

export default function DocumentPreview({ url, name, mime, onClose }: DocPreviewProps) {
  const [blobUrl, setBlobUrl] = useState<string | null>(null);
  const [textContent, setTextContent] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  const Icon = fileIcon(mime);
  const ext = name.split('.').pop()?.toLowerCase() ?? '';
  const isText = ext === 'txt' || ext === 'csv' || ext === 'md' || mime.startsWith('text/');
  const isPdf = ext === 'pdf' || mime.includes('pdf');
  const isOffice = ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].includes(ext);
  const isImage = mime.startsWith('image/');

  useEffect(() => {
    (async () => {
      try {
        const response = await apiClient.get(url, { responseType: 'blob' });
        const blob = new Blob([response.data], { type: String(response.headers['content-type'] || mime || 'application/octet-stream') });

        if (isText) {
          const text = await blob.text();
          setTextContent(text);
        }

        const bUrl = URL.createObjectURL(blob);
        setBlobUrl(bUrl);
      } catch {
        setError(true);
      } finally {
        setLoading(false);
      }
    })();
    return () => { if (blobUrl) URL.revokeObjectURL(blobUrl); };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [url]);

  const handleDownload = async () => {
    try {
      const r = await apiClient.get(url, { responseType: 'blob' });
      const blob = new Blob([r.data], { type: String(r.headers['content-type'] || mime || 'application/octet-stream') });
      const dlUrl = URL.createObjectURL(blob);
      const a = document.createElement('a'); a.href = dlUrl; a.download = name; a.click();
      URL.revokeObjectURL(dlUrl);
    } catch {
      window.open(url, '_blank');
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm" onClick={onClose}>
      <div className="bg-buddy-surface w-full max-w-4xl h-[85vh] rounded-2xl overflow-hidden flex flex-col shadow-2xl" onClick={e => e.stopPropagation()}>
        {/* Header */}
        <div className="flex items-center justify-between px-4 py-3 border-b border-white/10 bg-buddy-surface-raised shrink-0">
          <div className="flex items-center gap-2 min-w-0">
            <Icon size={18} className="text-buddy-green shrink-0" />
            <span className="font-semibold text-sm truncate text-buddy-text-primary">{name}</span>
            {ext && <span className="text-[10px] uppercase text-buddy-text-secondary font-mono">.{ext}</span>}
          </div>
          <div className="flex items-center gap-1">
            <button onClick={handleDownload} className="p-2 hover:bg-white/10 rounded-full transition-colors text-buddy-text-secondary hover:text-buddy-text-primary" title="Download">
              <Download size={18} />
            </button>
            <button onClick={onClose} className="p-2 hover:bg-white/10 rounded-full transition-colors text-buddy-text-secondary hover:text-buddy-text-primary">
              <X size={18} />
            </button>
          </div>
        </div>

        {/* Body */}
        <div className="flex-1 overflow-hidden bg-white/5">
          {loading ? (
            <div className="h-full flex items-center justify-center">
              <div className="w-8 h-8 border-2 border-buddy-green border-t-transparent rounded-full animate-spin" />
            </div>
          ) : error ? (
            <div className="h-full flex flex-col items-center justify-center gap-4 text-buddy-text-secondary">
              <FileText size={48} className="opacity-40" />
              <p className="text-sm">Failed to load preview</p>
              <button onClick={handleDownload} className="px-4 py-2 bg-buddy-green text-buddy-black rounded-xl text-sm font-semibold hover:scale-105 transition-transform">
                <Download size={16} className="inline mr-1.5 -mt-0.5" />Download Instead
              </button>
            </div>
          ) : isImage && blobUrl ? (
            <div className="h-full flex items-center justify-center p-4">
              <img src={blobUrl} alt={name} className="max-h-full max-w-full object-contain rounded-lg" />
            </div>
          ) : isPdf && blobUrl ? (
            <embed src={blobUrl} type="application/pdf" className="w-full h-full" />
          ) : isText && textContent !== null ? (
            <div className="h-full overflow-y-auto p-6">
              <pre className="text-sm text-buddy-text-primary font-mono whitespace-pre-wrap leading-relaxed">{textContent}</pre>
            </div>
          ) : (
            <div className="h-full flex flex-col items-center justify-center gap-4 text-buddy-text-secondary">
              <Icon size={64} className="opacity-30" />
              <p className="text-sm font-medium">Preview not available for this file type</p>
              <p className="text-xs opacity-60">{mime || 'Unknown type'}</p>
              <button onClick={handleDownload} className="px-5 py-2.5 bg-buddy-green text-buddy-black rounded-xl text-sm font-semibold hover:scale-105 transition-transform mt-2">
                <Download size={16} className="inline mr-1.5 -mt-0.5" />Download
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
