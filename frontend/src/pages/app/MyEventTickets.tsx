import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Calendar, MapPin, Tag, Download } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { marketplaceApi } from '@/api/marketplace';
import { QRCodeSVG } from 'qrcode.react';

export default function MyEventTickets() {
  const navigate = useNavigate();
  const [tickets, setTickets] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    marketplaceApi.getMyTickets()
      .then(res => setTickets(res.data))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, []);

  const handleDownload = (ticket: any) => {
    const svg = document.getElementById(`qr-${ticket.id}`);
    if (!svg) return;
    
    const svgData = new XMLSerializer().serializeToString(svg);
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    const img = new Image();
    
    img.onload = () => {
      canvas.width = img.width;
      canvas.height = img.height + 60; // Extra space for text
      if (ctx) {
        ctx.fillStyle = 'white';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.drawImage(img, 0, 0);
        
        ctx.fillStyle = 'black';
        ctx.font = '20px sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText(ticket.event_data?.title || 'Event Ticket', canvas.width / 2, img.height + 30);
        
        const pngFile = canvas.toDataURL('image/png');
        const downloadLink = document.createElement('a');
        downloadLink.download = `ticket-${ticket.ticket_code}.png`;
        downloadLink.href = `${pngFile}`;
        downloadLink.click();
      }
    };
    img.src = 'data:image/svg+xml;base64,' + btoa(unescape(encodeURIComponent(svgData)));
  };

  if (isLoading) return <div className="p-4 text-center">Loading tickets...</div>;

  return (
    <div className="max-w-lg mx-auto p-4">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate(-1)} className="text-buddy-text-secondary hover:text-buddy-text-primary transition-colors">
          <ArrowLeft size={20} />
        </button>
        <h1 className="text-2xl font-bold">My Tickets</h1>
      </div>

      {tickets.length === 0 ? (
        <div className="text-center py-20 text-buddy-text-secondary bg-buddy-surface rounded-2xl">
          <Tag size={48} className="mx-auto mb-4 opacity-20" />
          <p>You haven't bought any tickets yet.</p>
          <Button variant="ghost" onClick={() => navigate('/marketplace')} className="mt-4">
            Browse Events
          </Button>
        </div>
      ) : (
        <div className="space-y-6">
          {tickets.map(ticket => (
            <Card key={ticket.id} className="overflow-hidden border-none bg-buddy-surface">
              <div className="flex flex-col sm:flex-row">
                <div className="p-5 flex-1 flex flex-col justify-between">
                  <div>
                    <div className="flex justify-between items-start mb-2">
                      <h3 className="font-bold text-xl">{ticket.event_data?.title}</h3>
                      <div className={`px-2 py-0.5 rounded text-xs font-bold uppercase tracking-wider ${ticket.status === 'active' ? 'bg-buddy-green/20 text-buddy-green' : 'bg-buddy-surface-raised text-buddy-text-secondary'}`}>
                        {ticket.status}
                      </div>
                    </div>
                    <p className="text-sm text-buddy-text-secondary mb-4">Ticket ID: {ticket.ticket_code.split('-')[0]}</p>
                  </div>
                  
                  <div className="space-y-2">
                    <div className="flex items-center gap-2 text-sm">
                      <Calendar size={16} className="text-buddy-green" />
                      <span>{new Date(ticket.event_data?.start_datetime).toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}</span>
                    </div>
                    {ticket.event_data?.location && (
                      <div className="flex items-center gap-2 text-sm text-buddy-text-secondary">
                        <MapPin size={16} />
                        <span>{ticket.event_data.location}</span>
                      </div>
                    )}
                  </div>
                </div>
                
                <div className="bg-buddy-surface-raised p-5 flex flex-col items-center justify-center border-t sm:border-t-0 sm:border-l border-dashed border-buddy-text-secondary/30 relative">
                  {/* Perforation circles */}
                  <div className="hidden sm:block absolute -top-3 -left-3 w-6 h-6 bg-buddy-black rounded-full"></div>
                  <div className="hidden sm:block absolute -bottom-3 -left-3 w-6 h-6 bg-buddy-black rounded-full"></div>
                  <div className="block sm:hidden absolute -top-3 -left-3 w-6 h-6 bg-buddy-black rounded-full"></div>
                  <div className="block sm:hidden absolute -top-3 -right-3 w-6 h-6 bg-buddy-black rounded-full"></div>
                  
                  <div className="bg-white p-2 rounded-xl mb-3">
                    <QRCodeSVG 
                      id={`qr-${ticket.id}`}
                      value={ticket.ticket_code} 
                      size={120} 
                      level="H" 
                    />
                  </div>
                  <Button size="sm" variant="ghost" onClick={() => handleDownload(ticket)} className="w-full">
                    <Download size={14} className="mr-2" /> Download
                  </Button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
