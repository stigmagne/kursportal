'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Plus, Trash2, Video, FileText, File as FileIcon, HelpCircle, GripVertical } from 'lucide-react';

interface ContentBlock {
    id: string;
    lesson_id: string;
    type: 'text' | 'video' | 'quiz' | 'file' | 'expert_video';
    order_index: number;
    text_content: string | null;
    video_url: string | null;
    quiz_id: string | null;
    file_url: string | null;
    file_name: string | null;
    expert_video_data: {
        video_url: string;
        expert_name: string;
        expert_title: string;
        expert_image_url: string;
    } | null;
}

export default function ContentBlockEditor({ lessonId }: { lessonId: string }) {
    const [blocks, setBlocks] = useState<ContentBlock[]>([]);
    const [newBlockType, setNewBlockType] = useState<'text' | 'video' | 'file' | 'expert_video'>('text');
    const supabase = createClient();

    useEffect(() => {
        fetchBlocks();
    }, [lessonId]);

    const fetchBlocks = async () => {
        const { data } = await supabase
            .from('lesson_content')
            .select('*')
            .eq('lesson_id', lessonId)
            .order('order_index');

        if (data) {
            setBlocks(data);
        }
    };

    const addBlock = async () => {
        try {
            const { data, error } = await supabase
                .from('lesson_content')
                .insert({
                    lesson_id: lessonId,
                    type: newBlockType,
                    order_index: blocks.length,
                    text_content: newBlockType === 'text' ? '# Enter your content here\n\nUse markdown formatting...' : null,
                    video_url: newBlockType === 'video' ? 'https://www.youtube.com/watch?v=' : null,
                })
                .select()
                .single();

            if (error) throw error;
            setBlocks([...blocks, data]);
        } catch (error: any) {
            alert('Error adding content block: ' + error.message);
        }
    };

    const updateBlock = async (blockId: string, updates: Partial<ContentBlock>) => {
        try {
            const { error } = await supabase
                .from('lesson_content')
                .update(updates)
                .eq('id', blockId);

            if (error) throw error;

            setBlocks(blocks.map(b =>
                b.id === blockId ? { ...b, ...updates } : b
            ));
        } catch (error: any) {
            alert('Error updating block: ' + error.message);
        }
    };

    const deleteBlock = async (blockId: string) => {
        if (!confirm('Delete this content block?')) return;

        try {
            const { error } = await supabase
                .from('lesson_content')
                .delete()
                .eq('id', blockId);

            if (error) throw error;
            setBlocks(blocks.filter(b => b.id !== blockId));
        } catch (error: any) {
            alert('Error deleting block: ' + error.message);
        }
    };

    const getBlockIcon = (type: string) => {
        switch (type) {
            case 'video': return <Video className="w-4 h-4" />;
            case 'text': return <FileText className="w-4 h-4" />;
            case 'quiz': return <HelpCircle className="w-4 h-4" />;
            case 'file': return <FileIcon className="w-4 h-4" />;
            case 'expert_video': return <Video className="w-4 h-4 text-purple-500" />;
            default: return <FileText className="w-4 h-4" />;
        }
    };

    return (
        <div className="space-y-3 mt-3">
            <div className="flex items-center justify-between">
                <h5 className="text-sm font-medium text-muted-foreground">Content Blocks</h5>
                <div className="flex gap-2">
                    <select
                        value={newBlockType}
                        onChange={(e) => setNewBlockType(e.target.value as any)}
                        className="text-xs px-2 py-1 rounded border border-border bg-background"
                    >
                        <option value="text">📝 Text</option>
                        <option value="video">🎥 Video</option>
                        <option value="file">📎 File</option>
                        <option value="expert_video">👨‍🏫 Expert Video</option>
                    </select>
                    <button
                        onClick={addBlock}
                        className="text-xs px-2 py-1 bg-primary/20 text-primary rounded hover:bg-primary/30"
                    >
                        <Plus className="w-3 h-3" />
                    </button>
                </div>
            </div>

            {blocks.length === 0 ? (
                <p className="text-xs text-muted-foreground text-center py-4">
                    No content yet. Add blocks to build your lesson.
                </p>
            ) : (
                <div className="space-y-2">
                    {blocks.map((block) => (
                        <div key={block.id} className="border border-border rounded-lg p-3 bg-background/50">
                            <div className="flex items-start gap-2 mb-2">
                                <GripVertical className="w-3 h-3 mt-1 text-muted-foreground cursor-grab" />
                                <div className="flex items-center gap-2 flex-1">
                                    {getBlockIcon(block.type)}
                                    <span className="text-xs font-medium capitalize">{block.type}</span>
                                </div>
                                <button
                                    onClick={() => deleteBlock(block.id)}
                                    className="text-muted-foreground hover:text-destructive"
                                >
                                    <Trash2 className="w-3 h-3" />
                                </button>
                            </div>

                            {block.type === 'text' && (
                                <textarea
                                    value={block.text_content || ''}
                                    onChange={(e) => updateBlock(block.id, { text_content: e.target.value })}
                                    className="w-full px-2 py-1.5 text-xs border border-border rounded bg-background font-mono"
                                    rows={4}
                                    placeholder="Enter markdown content..."
                                />
                            )}

                            {block.type === 'video' && (
                                <div className="space-y-2">
                                    <input
                                        type="url"
                                        value={block.video_url || ''}
                                        onChange={(e) => updateBlock(block.id, { video_url: e.target.value })}
                                        className="w-full px-2 py-1.5 text-xs border border-border rounded bg-background"
                                        placeholder="YouTube or Vimeo URL"
                                    />
                                    <p className="text-xs text-muted-foreground">
                                        Paste a YouTube or Vimeo link
                                    </p>
                                </div>
                            )}

                            {block.type === 'file' && (
                                <div className="space-y-2">
                                    <input
                                        type="text"
                                        value={block.file_name || ''}
                                        onChange={(e) => updateBlock(block.id, { file_name: e.target.value })}
                                        className="w-full px-2 py-1.5 text-xs border border-border rounded bg-background"
                                        placeholder="File name (e.g., worksheet.pdf)"
                                    />
                                    <input
                                        type="url"
                                        value={block.file_url || ''}
                                        onChange={(e) => updateBlock(block.id, { file_url: e.target.value })}
                                        className="w-full px-2 py-1.5 text-xs border border-border rounded bg-background"
                                        placeholder="File URL (upload to Supabase storage)"
                                    />
                                </div>
                            )}

                            {block.type === 'expert_video' && (
                                <div className="space-y-2 border-l-2 border-primary/20 pl-3">
                                    <p className="text-xs font-semibold text-primary">Expert Video Details</p>
                                    <input
                                        type="url"
                                        value={block.expert_video_data?.video_url || ''}
                                        onChange={(e) => updateBlock(block.id, {
                                            expert_video_data: { ...(block.expert_video_data as any), video_url: e.target.value }
                                        })}
                                        className="w-full px-2 py-1.5 text-xs border border-border rounded bg-background"
                                        placeholder="Video URL (Vimeo/YouTube)"
                                    />
                                    <div className="grid grid-cols-2 gap-2">
                                        <input
                                            type="text"
                                            value={block.expert_video_data?.expert_name || ''}
                                            onChange={(e) => updateBlock(block.id, {
                                                expert_video_data: { ...(block.expert_video_data as any), expert_name: e.target.value }
                                            })}
                                            className="w-full px-2 py-1.5 text-xs border border-border rounded bg-background"
                                            placeholder="Expert Name"
                                        />
                                        <input
                                            type="text"
                                            value={block.expert_video_data?.expert_title || ''}
                                            onChange={(e) => updateBlock(block.id, {
                                                expert_video_data: { ...(block.expert_video_data as any), expert_title: e.target.value }
                                            })}
                                            className="w-full px-2 py-1.5 text-xs border border-border rounded bg-background"
                                            placeholder="Expert Title (e.g. Senior Engineer)"
                                        />
                                    </div>
                                    <input
                                        type="url"
                                        value={block.expert_video_data?.expert_image_url || ''}
                                        onChange={(e) => updateBlock(block.id, {
                                            expert_video_data: { ...(block.expert_video_data as any), expert_image_url: e.target.value }
                                        })}
                                        className="w-full px-2 py-1.5 text-xs border border-border rounded bg-background"
                                        placeholder="Expert Profile Image URL"
                                    />
                                </div>
                            )}
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}
