'use client';

import { PlayCircle } from 'lucide-react';

interface ExpertVideoData {
    video_url: string;
    expert_name: string;
    expert_title: string;
    expert_image_url: string;
}

interface ExpertVideoViewProps {
    data: ExpertVideoData | string;
}

export function ExpertVideoView({ data }: ExpertVideoViewProps) {
    let content: ExpertVideoData;
    try {
        content = typeof data === 'string' ? JSON.parse(data) : data;
    } catch (e) {
        return (
            <div className="p-4 border-2 border-red-500 bg-red-50 text-red-700 rounded-lg">
                Error rendering expert video
            </div>
        );
    }

    const { video_url, expert_name, expert_title, expert_image_url } = content;

    return (
        <div className="space-y-6 my-8 not-prose">
            {/* Video Player Section */}
            <div className="rounded-lg overflow-hidden border-2 border-black dark:border-white shadow-[4px_4px_0_0_#000] dark:shadow-[4px_4px_0_0_#fff]">
                {video_url ? (
                    video_url.includes('youtube.com') || video_url.includes('youtu.be') ? (
                        <iframe
                            src={video_url.replace('watch?v=', 'embed/').replace('youtu.be/', 'youtube.com/embed/')}
                            className="w-full aspect-video"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                            allowFullScreen
                        />
                    ) : video_url.includes('vimeo.com') ? (
                        <iframe
                            src={video_url.replace('vimeo.com/', 'player.vimeo.com/video/')}
                            className="w-full aspect-video"
                            allow="autoplay; fullscreen; picture-in-picture"
                            allowFullScreen
                        />
                    ) : (
                        <video src={video_url} controls className="w-full aspect-video" />
                    )
                ) : (
                    <div className="w-full aspect-video bg-muted flex flex-col items-center justify-center">
                        <PlayCircle className="w-12 h-12 text-muted-foreground/50 mb-2" />
                        <p className="text-muted-foreground text-sm">Ingen video tilgjengelig</p>
                    </div>
                )}
            </div>

            {/* Expert Profile Card */}
            <div className="flex items-center gap-6 p-6 bg-purple-50 dark:bg-purple-950/20 border-2 border-purple-500 rounded-lg shadow-[4px_4px_0_0_#a855f7]">
                <div className="shrink-0">
                    {expert_image_url ? (
                        <img
                            src={expert_image_url}
                            alt={expert_name}
                            className="w-20 h-20 rounded-full border-2 border-purple-500 object-cover"
                        />
                    ) : (
                        <div className="w-20 h-20 rounded-full border-2 border-purple-500 bg-purple-200 dark:bg-purple-800 flex items-center justify-center text-2xl">
                            👨‍🏫
                        </div>
                    )}
                </div>
                <div>
                    <h3 className="text-lg font-bold text-purple-900 dark:text-purple-100 mb-1">
                        Møt eksperten
                    </h3>
                    <p className="text-xl font-bold text-foreground">
                        {expert_name || 'Ukjent Ekspert'}
                    </p>
                    <p className="text-purple-700 dark:text-purple-300 font-medium">
                        {expert_title || 'Fagperson'}
                    </p>
                </div>
            </div>
        </div>
    );
}
