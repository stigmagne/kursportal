export default function CourseLoading() {
    return (
        <div className="max-w-4xl mx-auto space-y-8 px-4 py-8">
            <div className="h-64 bg-muted rounded-xl animate-pulse"></div>
            <div className="space-y-4">
                <div className="h-8 bg-muted rounded w-1/2 animate-pulse"></div>
                <div className="h-4 bg-muted rounded animate-pulse"></div>
                <div className="h-4 bg-muted rounded w-5/6 animate-pulse"></div>
                <div className="h-4 bg-muted rounded w-4/6 animate-pulse"></div>
            </div>
            <div className="grid gap-4">
                {[1, 2, 3].map((i) => (
                    <div key={i} className="glass rounded-xl p-6 space-y-3">
                        <div className="h-6 bg-muted rounded w-1/3 animate-pulse"></div>
                        <div className="h-4 bg-muted rounded animate-pulse"></div>
                    </div>
                ))}
            </div>
        </div>
    );
}
