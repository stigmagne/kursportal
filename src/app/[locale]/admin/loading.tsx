export default function AdminLoading() {
    return (
        <div className="space-y-6">
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
                {[1, 2, 3, 4].map((i) => (
                    <div key={i} className="glass rounded-xl p-6 space-y-3">
                        <div className="h-4 bg-muted rounded w-1/2 animate-pulse"></div>
                        <div className="h-8 bg-muted rounded w-3/4 animate-pulse"></div>
                    </div>
                ))}
            </div>
            <div className="glass rounded-xl p-6 space-y-4">
                <div className="h-6 bg-muted rounded w-1/4 animate-pulse"></div>
                <div className="space-y-3">
                    {[1, 2, 3, 4, 5].map((i) => (
                        <div key={i} className="h-16 bg-muted rounded animate-pulse"></div>
                    ))}
                </div>
            </div>
        </div>
    );
}
