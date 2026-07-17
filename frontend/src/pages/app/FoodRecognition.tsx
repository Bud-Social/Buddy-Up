import { useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { Camera, Upload, RotateCcw, Sparkles, BarChart3, AlertCircle } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { marketplaceApi } from '@/api/marketplace';
import type { FoodRecognitionResult, FoodItem } from '@/api/marketplace';

export default function FoodRecognition() {
  const navigate = useNavigate();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const [file, setFile] = useState<File | null>(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [result, setResult] = useState<FoodRecognitionResult | null>(null);
  const [error, setError] = useState('');

  const handleFile = (f: File) => {
    if (!f.type.startsWith('image/')) {
      setError('Please select an image file.');
      return;
    }
    setError('');
    setResult(null);
    setFile(f);
    const reader = new FileReader();
    reader.onload = (e) => setPreview(e.target?.result as string);
    reader.readAsDataURL(f);
  };

  const handleCapture = () => fileInputRef.current?.click();

  const handleAnalyze = async () => {
    if (!file) return;
    setIsAnalyzing(true);
    setError('');
    try {
      const res = await marketplaceApi.recognizeFood(file);
      setResult(res.data);
    } catch {
      setError('Analysis failed. Please try again.');
    } finally {
      setIsAnalyzing(false);
    }
  };

  const handleReset = () => {
    setPreview(null);
    setFile(null);
    setResult(null);
    setError('');
  };

  return (
    <div className="max-w-lg mx-auto p-4 space-y-4">
      <h1 className="font-display text-2xl font-extrabold">Food Scanner</h1>
      <p className="text-buddy-text-secondary">Take a photo of your meal to get nutritional insights.</p>

      {!preview ? (
        <Card className="p-8 text-center">
          <div
            onClick={handleCapture}
            className="border-2 border-dashed border-buddy-surface-raised rounded-2xl p-12 cursor-pointer hover:border-buddy-green/50 transition-colors"
          >
            <Camera className="w-12 h-12 text-buddy-text-secondary mx-auto mb-4" />
            <p className="text-buddy-text-secondary mb-4">Tap to take a photo or upload</p>
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              capture="environment"
              className="hidden"
              onChange={(e) => e.target.files?.[0] && handleFile(e.target.files[0])}
            />
            <div className="flex gap-2 justify-center">
              <Button variant="secondary" onClick={(e) => { e.stopPropagation(); fileInputRef.current?.click(); }}>
                <Upload className="w-4 h-4 mr-2" /> Upload
              </Button>
            </div>
          </div>
        </Card>
      ) : (
        <Card className="p-4">
          <div className="relative">
            <img src={preview} alt="Food" className="w-full rounded-xl object-cover max-h-80" />
            <button
              onClick={handleReset}
              className="absolute top-2 right-2 bg-buddy-black/60 p-2 rounded-full hover:bg-buddy-black/80 transition-colors"
            >
              <RotateCcw className="w-4 h-4" />
            </button>
          </div>

          {!result && (
            <Button
              onClick={handleAnalyze}
              disabled={isAnalyzing}
              className="w-full mt-4"
              size="lg"
            >
              {isAnalyzing ? (
                <><div className="w-5 h-5 border-2 border-buddy-black border-t-transparent rounded-full animate-spin mr-2" /> Analyzing...</>
              ) : (
                <><Sparkles className="w-5 h-5 mr-2" /> Analyze Meal</>
              )}
            </Button>
          )}
        </Card>
      )}

      {error && (
        <div className="bg-buddy-red/10 border border-buddy-red/30 rounded-xl p-4 flex items-start gap-3">
          <AlertCircle className="w-5 h-5 text-buddy-red flex-shrink-0 mt-0.5" />
          <p className="text-buddy-red text-sm">{error}</p>
        </div>
      )}

      {result && (
        <div className="space-y-4">
          <Card className="p-4">
            <div className="flex items-center gap-2 mb-4">
              <BarChart3 className="w-5 h-5 text-buddy-green" />
              <h2 className="font-heading font-semibold">Nutrition Summary</h2>
            </div>
            <div className="grid grid-cols-4 gap-3 mb-4">
              {[
                { label: 'Calories', value: `${result.total_calories}`, color: 'text-buddy-orange' },
                { label: 'Protein', value: `${result.total_protein}g`, color: 'text-buddy-green' },
                { label: 'Carbs', value: `${result.total_carbs}g`, color: 'text-blue-400' },
                { label: 'Fat', value: `${result.total_fat}g`, color: 'text-buddy-red' },
              ].map((m) => (
                <div key={m.label} className="bg-buddy-surface rounded-xl p-3 text-center">
                  <p className={`text-lg font-bold ${m.color}`}>{m.value}</p>
                  <p className="text-xs text-buddy-text-secondary">{m.label}</p>
                </div>
              ))}
            </div>

            <h3 className="font-heading font-semibold text-sm mb-2">Detected Items</h3>
            <div className="space-y-2">
              {result.items.map((item: FoodItem, i: number) => (
                <div key={i} className="flex items-center justify-between bg-buddy-surface rounded-xl px-3 py-2">
                  <div>
                    <p className="font-medium text-sm capitalize">{item.item}</p>
                    <p className="text-xs text-buddy-text-secondary">
                      {(item.confidence * 100).toFixed(0)}% confidence
                    </p>
                  </div>
                  <Badge variant="green" label={`${item.nutrition.calories} cal`} />
                </div>
              ))}
            </div>
          </Card>

          {result.health_benefits.length > 0 && (
            <Card className="p-4">
              <h3 className="font-heading font-semibold text-sm mb-3">Health Benefits</h3>
              <div className="flex flex-wrap gap-2">
                {result.health_benefits.map((b: string, i: number) => (
                  <Badge key={i} variant="blue" label={b} />
                ))}
              </div>
            </Card>
          )}

          <Button
            variant="secondary"
            className="w-full"
            onClick={() => navigate('/feed', { state: { mealData: result } })}
          >
            Share as Meal Post
          </Button>
        </div>
      )}
    </div>
  );
}
