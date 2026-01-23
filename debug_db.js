
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
    console.error('Missing env vars');
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function debugData() {
    console.log('--- Debugging Data ---');

    // 1. Get recent users
    const { data: users, error: userError } = await supabase
        .from('profiles')
        .select('id, email, full_name, role, user_category')
        .order('created_at', { ascending: false })
        .limit(5);

    if (userError) console.error('User Error:', userError);
    console.log('Recent Users:', users);

    // 2. Get published courses
    const { data: courses, error: courseError } = await supabase
        .from('courses')
        .select('id, title, published, target_groups')
        .eq('published', true);

    if (courseError) console.error('Course Error:', courseError);
    console.log('Published Courses:', courses);
}

debugData();
