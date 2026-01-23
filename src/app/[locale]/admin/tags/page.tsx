import TagsList from '@/components/admin/tags/TagsList';

export default function AdminTagsPage() {
    return (
        <div className="p-8 max-w-7xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">Tags</h1>
                <p className="text-muted-foreground mt-2">
                    Administrer tags som brukes til å kategorisere kurs.
                </p>
            </div>

            <TagsList />
        </div>
    );
}
