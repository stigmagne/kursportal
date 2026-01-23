-- Migration: Add Course Status/Lifecycle Management
-- This adds a status field to courses for better lifecycle management

-- Add status enum and field to courses
DO $$ 
BEGIN
    -- Create enum type if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'course_status') THEN
        CREATE TYPE course_status AS ENUM ('active', 'paused', 'archived', 'legacy');
    END IF;
END $$;

-- Add status column with default 'active'
ALTER TABLE public.courses 
ADD COLUMN IF NOT EXISTS status course_status DEFAULT 'active';

-- Update existing courses to be active
UPDATE public.courses SET status = 'active' WHERE status IS NULL;

-- Add index for faster status queries
CREATE INDEX IF NOT EXISTS idx_courses_status ON public.courses(status);

COMMENT ON COLUMN public.courses.status IS 
'Course status: active (visible and enrollable), paused (hidden but can be reactivated), archived (read-only for enrolled), legacy (read-only, historical data preserved)';
