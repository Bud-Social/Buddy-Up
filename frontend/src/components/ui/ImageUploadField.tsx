import React, { useState, useRef } from 'react';
import { Upload, X, Loader2 } from 'lucide-react';
import { marketplaceApi } from '@/api/marketplace';

interface ImageUploadFieldProps {
  value?: string;
  onChange: (url: string) => void;
  className?: string;
  label?: string;
}

export function ImageUploadField({ value, onChange, className = '', label = 'Upload Image' }: ImageUploadFieldProps) {
  const [isUploading, setIsUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsUploading(true);
    setError(null);
    try {
      const res = await marketplaceApi.uploadImage(file);
      if (res.data?.url) {
        onChange(res.data.url);
      } else {
        setError('Upload failed, no URL returned.');
      }
    } catch (err) {
      setError('An error occurred during upload.');
    } finally {
      setIsUploading(false);
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
    }
  };

  const handleClear = (e: React.MouseEvent) => {
    e.stopPropagation();
    onChange('');
  };

  return (
    <div className={`flex flex-col gap-2 ${className}`}>
      {label && <span className="text-sm font-medium text-buddy-text-primary">{label}</span>}
      
      <div 
        className="relative flex items-center justify-center w-full h-32 border-2 border-dashed border-buddy-surface-raised rounded-xl overflow-hidden bg-buddy-surface cursor-pointer hover:bg-buddy-surface-raised transition-colors"
        onClick={() => fileInputRef.current?.click()}
      >
        <input 
          type="file" 
          ref={fileInputRef}
          className="hidden" 
          accept="image/*"
          onChange={handleFileChange}
        />
        
        {isUploading ? (
          <div className="flex flex-col items-center gap-2 text-buddy-electric">
            <Loader2 className="animate-spin" size={24} />
            <span className="text-xs">Uploading...</span>
          </div>
        ) : value ? (
          <>
            <img src={value} alt="Uploaded" className="w-full h-full object-cover" />
            <button 
              onClick={handleClear}
              className="absolute top-2 right-2 bg-buddy-black/70 text-white p-1 rounded-full hover:bg-buddy-black transition-colors"
            >
              <X size={16} />
            </button>
          </>
        ) : (
          <div className="flex flex-col items-center gap-2 text-buddy-text-secondary">
            <Upload size={24} />
            <span className="text-xs">Click to upload image</span>
          </div>
        )}
      </div>
      {error && <span className="text-xs text-red-500">{error}</span>}
    </div>
  );
}
