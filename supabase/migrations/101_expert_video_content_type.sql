-- Migration 101: Add Expert Video Content Type
-- Adds 'expert_video' to content_type enum and adds storage column

-- 1. Add 'expert_video' to content_type enum
-- Safe block for enum addition
DO $$
BEGIN
    ALTER TYPE content_type ADD VALUE IF NOT EXISTS 'expert_video';
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Add expert_video_data column to lesson_content
ALTER TABLE public.lesson_content
ADD COLUMN IF NOT EXISTS expert_video_data JSONB;

COMMENT ON COLUMN public.lesson_content.expert_video_data IS 'Structured data for expert videos: { "video_url": "...", "expert_name": "...", "expert_title": "...", "expert_image_url": "..." }';
