import { Skeleton } from '@/components/ui/Skeleton';

export default function CoursesLoading() {
    return (
        <div className="space-y-6">
            <div className="h-8 bg-muted rounded w-1/4 animate-pulse"></div>
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                {[1, 2, 3, 4, 5, 6].map((i) => (
                    <div key={i} className="glass rounded-xl p-6 space-y-4">
                        <div className="h-48 bg-muted rounded animate-pulse"></div>
                        <div className="h-6 bg-muted rounded w-3/4 animate-pulse"></div>
                        <div className="h-4 bg-muted rounded animate-pulse"></div>
                        <div className="h-4 bg-muted rounded w-5/6 animate-pulse"></div>
                    </div>
                ))}
            </div>
        </div>
    );
}
