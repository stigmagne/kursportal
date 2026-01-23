import { LucideIcon } from 'lucide-react';

interface StatsCardProps {
    title: string;
    value: string | number;
    icon: LucideIcon;
    iconColor?: string;
}

export default function StatsCard({ title, value, icon: Icon, iconColor = 'text-primary' }: StatsCardProps) {
    return (
        <div className="glass p-6 rounded-xl border border-white/10 hover:border-primary/50 transition-all">
            <div className="flex items-center gap-4">
                <div className={`p-3 rounded-lg bg-primary/10 ${iconColor}`}>
                    <Icon className="w-6 h-6" />
                </div>
                <div>
                    <p className="text-sm text-muted-foreground mb-1">{title}</p>
                    <p className="text-2xl font-bold">{value}</p>
                </div>
            </div>
        </div>
    );
}
