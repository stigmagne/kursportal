'use client';

import ReactMarkdown from 'react-markdown';
import { FileText, Download } from 'lucide-react';
import QuizTaker from './QuizTaker';

interface LessonViewerProps {
    lesson: any;
    userId: string;
}

export default function LessonViewer({ lesson, userId }: LessonViewerProps) {
    const contentBlocks = lesson.lesson_content?.sort((a: any, b: any) => a.order_index - b.order_index) || [];

    // Check if lesson has direct content (markdown string from migrations)
    const hasDirectContent = lesson.content && lesson.content.trim().length > 0;
    // Check if lesson has content blocks (from lesson_content table)
    const hasContentBlocks = contentBlocks.length > 0;

    return (
        <div className="max-w-4xl mx-auto px-6 py-8">
            {/* Lesson Header */}
            <div className="mb-8">
                <h1 className="text-3xl font-bold mb-2">{lesson.title}</h1>
                {lesson.description && (
                    <p className="text-muted-foreground">{lesson.description}</p>
                )}
                {lesson.duration_minutes && (
                    <p className="text-sm text-muted-foreground mt-2">
                        ⏱️ Estimated time: {lesson.duration_minutes} minutes
                    </p>
                )}
            </div>

            {/* Direct Content (from lessons.content column) */}
            {hasDirectContent && (
                <div className="prose dark:prose-invert max-w-none mb-8">
                    <ReactMarkdown>{lesson.content}</ReactMarkdown>
                </div>
            )}

            {/* Content Blocks (from lesson_content table) */}
            {!hasDirectContent && !hasContentBlocks ? (
                <div className="text-center py-12 text-muted-foreground">
                    <FileText className="w-12 h-12 mx-auto mb-4 opacity-50" />
                    <p>No content available for this lesson yet.</p>
                </div>
            ) : hasContentBlocks && (
                <div className="space-y-8">
                    {contentBlocks.map((block: any) => (
                        <div key={block.id} className="content-block">
                            {block.type === 'text' && block.text_content && (
                                <div className="prose dark:prose-invert max-w-none">
                                    <ReactMarkdown>{block.text_content}</ReactMarkdown>
                                </div>
                            )}

                            {block.type === 'video' && block.video_url && (
                                <div className="rounded-lg overflow-hidden bg-black">
                                    {block.video_url.includes('youtube.com') || block.video_url.includes('youtu.be') ? (
                                        <iframe
                                            src={block.video_url.replace('watch?v=', 'embed/').replace('youtu.be/', 'youtube.com/embed/')}
                                            className="w-full aspect-video"
                                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                            allowFullScreen
                                        />
                                    ) : block.video_url.includes('vimeo.com') ? (
                                        <iframe
                                            src={block.video_url.replace('vimeo.com/', 'player.vimeo.com/video/')}
                                            className="w-full aspect-video"
                                            allow="autoplay; fullscreen; picture-in-picture"
                                            allowFullScreen
                                        />
                                    ) : (
                                        <video src={block.video_url} controls className="w-full aspect-video" />
                                    )}
                                </div>
                            )}

                            {block.type === 'file' && block.file_url && (
                                <a
                                    href={block.file_url}
                                    download={block.file_name}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="flex items-center gap-4 p-4 rounded-lg border border-border hover:bg-muted transition-colors"
                                >
                                    <div className="p-3 rounded-lg bg-primary/10 text-primary">
                                        <Download className="w-6 h-6" />
                                    </div>
                                    <div className="flex-1">
                                        <p className="font-medium">{block.file_name || 'Download File'}</p>
                                        <p className="text-sm text-muted-foreground">Click to download</p>
                                    </div>
                                </a>
                            )}
                        </div>
                    ))}
                </div>
            )}

            {/* Quiz Section */}
            <div className="mt-12 pt-8 border-t border-border">
                <h2 className="text-2xl font-bold mb-6">📝 Quiz</h2>
                <QuizTaker lessonId={lesson.id} userId={userId} />
            </div>
        </div>
    );
}
