'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '../ui/dialog';
import { Textarea } from '../ui/textarea';
import { importCourse } from '@/app/actions/admin-course-actions';
import { Loader2, FileJson, CheckCircle, AlertCircle } from 'lucide-react';
import { toast } from 'sonner';
import { useRouter } from 'next/navigation';

export default function CourseImporter() {
    const [open, setOpen] = useState(false);
    const [jsonInput, setJsonInput] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [parsedPreview, setParsedPreview] = useState<any>(null);
    const [error, setError] = useState<string | null>(null);
    const router = useRouter();

    const handleJsonChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
        const value = e.target.value;
        setJsonInput(value);
        setError(null);
        setParsedPreview(null);

        if (!value.trim()) return;

        try {
            const parsed = JSON.parse(value);
            // Basic validation
            if (parsed.title && Array.isArray(parsed.modules)) {
                setParsedPreview(parsed);
            } else {
                // Not a valid course object yet, but valid JSON
            }
        } catch (e) {
            // Invalid parsing, ignore for now until blur or submit? 
            // Or just don't show preview.
        }
    };

    const handleImport = async () => {
        if (!jsonInput.trim()) return;

        setIsLoading(true);
        setError(null);

        try {
            const result = await importCourse(jsonInput);

            if (result.success) {
                toast.success('Course imported successfully!');
                setOpen(false);
                setJsonInput('');
                setParsedPreview(null);
                router.refresh(); // Refresh existing list

                // Optional: Redirect to edit the new course
                if (result.courseId) {
                    // Check if we want to auto-redirect. Maybe just showing toast is better.
                    // router.push(`/admin/courses/edit/${result.courseId}`);
                }
            } else {
                setError(result.error || 'Unknown error occurred');
                toast.error('Import failed');
            }
        } catch (e: any) {
            setError(e.message);
            toast.error('Import failed');
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button variant="outline" className="gap-2">
                    <FileJson className="w-4 h-4" />
                    Import from AI
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[700px] max-h-[90vh] flex flex-col">
                <DialogHeader>
                    <DialogTitle>Import Course from JSON</DialogTitle>
                    <DialogDescription>
                        Paste the AI-generated JSON content here properly create the course structure.
                    </DialogDescription>
                </DialogHeader>

                <div className="grid gap-4 py-4 flex-1 overflow-y-auto">
                    <div className="space-y-2">
                        <label className="text-sm font-medium">JSON Data</label>
                        <Textarea
                            placeholder='{ "title": "My Course", "modules": [...] }'
                            className="font-mono text-sm h-[300px]"
                            value={jsonInput}
                            onChange={handleJsonChange}
                        />
                    </div>

                    {error && (
                        <div className="p-3 rounded-md bg-destructive/10 text-destructive text-sm flex items-center gap-2">
                            <AlertCircle className="w-4 h-4" />
                            {error}
                        </div>
                    )}

                    {parsedPreview && !error && (
                        <div className="p-4 rounded-md bg-muted border border-border space-y-2">
                            <div className="flex items-center gap-2 text-green-600 dark:text-green-400 font-medium">
                                <CheckCircle className="w-4 h-4" />
                                Valid JSON Structure
                            </div>
                            <div className="text-sm space-y-1">
                                <p><strong>Title:</strong> {parsedPreview.title}</p>
                                <p><strong>Modules:</strong> {parsedPreview.modules.length}</p>
                                <p><strong>Total Lessons:</strong> {parsedPreview.modules.reduce((Acc: number, m: any) => Acc + (m.lessons?.length || 0), 0)}</p>
                                {parsedPreview.tags?.length > 0 && (
                                    <p><strong>Tags:</strong> {parsedPreview.tags.join(', ')}</p>
                                )}
                            </div>
                        </div>
                    )}
                </div>

                <DialogFooter>
                    <Button variant="outline" onClick={() => setOpen(false)} disabled={isLoading}>
                        Cancel
                    </Button>
                    <Button onClick={handleImport} disabled={isLoading || !parsedPreview}>
                        {isLoading ? (
                            <>
                                <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                                Importing...
                            </>
                        ) : (
                            'Import Course'
                        )}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
}
