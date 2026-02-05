'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { useRouter } from 'next/navigation';
import { User, Mail, Calendar, Tag, Upload, Loader2, Save, Award, Activity, Edit2, X, FileText } from 'lucide-react';
import { motion } from 'framer-motion';
import { useTranslations, useLocale } from 'next-intl';
import { ActivityLog } from '@/components/profile/ActivityLog';
import { XPBar } from '@/components/gamification/XPBar';
import { StreakCounter } from '@/components/gamification/StreakCounter';
import { BadgeCollection } from '@/components/profile/BadgeCollection';
import CertificatePDF from '@/components/CertificatePDF';
import { getUserCertificates, type Certificate } from '@/app/actions/certificate-actions';

type Tab = 'overview' | 'badges' | 'activity' | 'certificates';

export default function ProfilePage() {
    const t = useTranslations('Profile');
    const tCerts = useTranslations('Certificates');
    const locale = useLocale();
    const supabase = createClient();
    const router = useRouter();
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [user, setUser] = useState<any>(null);
    const [profile, setProfile] = useState<any>(null);
    const [categories, setCategories] = useState<any[]>([]);
    const [streakData, setStreakData] = useState<any>(null);
    const [certificates, setCertificates] = useState<Certificate[]>([]);
    const [isEditing, setIsEditing] = useState(false);
    const [activeTab, setActiveTab] = useState<Tab>('overview');

    const [formData, setFormData] = useState({
        full_name: '',
        bio: '',
    });

    useEffect(() => {
        fetchProfile();
    }, []);

    const fetchProfile = async () => {
        try {
            const { data: { user } } = await supabase.auth.getUser();
            if (!user) {
                router.push('/login');
                return;
            }
            setUser(user);

            const { data: profileData } = await supabase
                .from('profiles')
                .select('*')
                .eq('id', user.id)
                .single();

            setProfile(profileData);
            setFormData({
                full_name: profileData?.full_name || '',
                bio: profileData?.bio || '',
            });

            // Fetch user's assigned categories
            const { data: userCats } = await supabase
                .from('user_categories')
                .select('*, categories(*)')
                .eq('user_id', user.id);

            setCategories(userCats || []);

            // Fetch user streak
            const { data: streak } = await supabase
                .from('user_streaks')
                .select('*')
                .eq('user_id', user.id)
                .single();

            setStreakData(streak);

            // Fetch user certificates
            const certsResult = await getUserCertificates();
            if (certsResult.success && certsResult.certificates) {
                setCertificates(certsResult.certificates);
            }
        } catch (error) {
            console.error('Error fetching profile:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSave = async () => {
        setSaving(true);
        try {
            const { error } = await supabase
                .from('profiles')
                .update({
                    full_name: formData.full_name,
                    bio: formData.bio,
                })
                .eq('id', user.id);

            if (error) throw error;

            setProfile({ ...profile, ...formData });
            setIsEditing(false);
        } catch (error: any) {
            alert(t('alerts.update_error') + ': ' + error.message);
        } finally {
            setSaving(false);
        }
    };

    const handleAvatarUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        try {
            const fileExt = file.name.split('.').pop();
            const fileName = `${user.id}-${Date.now()}.${fileExt}`;
            const filePath = `avatars/${fileName}`;

            const { error: uploadError } = await supabase.storage
                .from('avatars')
                .upload(filePath, file);

            if (uploadError) throw uploadError;

            const { data: { publicUrl } } = supabase.storage
                .from('avatars')
                .getPublicUrl(filePath);

            const { error: updateError } = await supabase
                .from('profiles')
                .update({ avatar_url: publicUrl })
                .eq('id', user.id);

            if (updateError) throw updateError;

            setProfile({ ...profile, avatar_url: publicUrl });
        } catch (error: any) {
            alert(t('alerts.upload_error') + ': ' + error.message);
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <Loader2 className="w-8 h-8 animate-spin text-primary" />
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-amber-50/50 py-12">
            <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="space-y-8"
                >
                    {/* Header Card */}
                    <div className="bg-white border-2 border-black shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] rounded-xl overflow-hidden">
                        <div className="h-32 bg-blue-500 border-b-2 border-black pattern-dots pattern-blue-600 pattern-bg-white pattern-size-4 pattern-opacity-10" />
                        <div className="px-8 pb-8">
                            <div className="flex flex-col md:flex-row items-start gap-6 -mt-12">
                                {/* Avatar */}
                                <div className="relative group">
                                    <div className="w-32 h-32 rounded-xl border-4 border-white ring-2 ring-black shadow-lg overflow-hidden bg-white relative">
                                        {profile?.avatar_url ? (
                                            <img src={profile.avatar_url} alt="Avatar" className="w-full h-full object-cover" />
                                        ) : (
                                            <div className="w-full h-full flex items-center justify-center bg-gray-100">
                                                <User className="w-16 h-16 text-gray-400" />
                                            </div>
                                        )}
                                        <label className="absolute inset-0 flex items-center justify-center bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity cursor-pointer">
                                            <Upload className="w-8 h-8 text-white" />
                                            <input
                                                type="file"
                                                accept="image/*"
                                                className="hidden"
                                                onChange={handleAvatarUpload}
                                            />
                                        </label>
                                    </div>
                                </div>

                                {/* User Info */}
                                <div className="flex-1 pt-4 md:pt-12 w-full md:w-auto">
                                    <div className="flex justify-between items-start">
                                        <div>
                                            <h1 className="text-3xl font-black tracking-tight flex items-center gap-2">
                                                {profile?.full_name || t('no_name')}
                                                {profile?.role === 'admin' && (
                                                    <span className="px-2 py-1 text-xs bg-black text-white rounded border border-black font-mono">
                                                        ADMIN
                                                    </span>
                                                )}
                                            </h1>
                                            <p className="text-lg text-gray-600 font-medium">{profile?.bio || t('no_bio')}</p>
                                        </div>
                                        <button
                                            onClick={() => setIsEditing(!isEditing)}
                                            className="p-2 bg-white border-2 border-black rounded-lg hover:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:-translate-y-1 transition-all active:translate-y-0 active:shadow-none"
                                        >
                                            {isEditing ? <X className="w-5 h-5" /> : <Edit2 className="w-5 h-5" />}
                                        </button>
                                    </div>

                                    {/* Edit Mode */}
                                    {isEditing && (
                                        <div className="mt-6 p-6 bg-yellow-50 border-2 border-black rounded-xl shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] space-y-4">
                                            <div>
                                                <label className="block text-sm font-bold mb-2">{t('full_name')}</label>
                                                <input
                                                    type="text"
                                                    value={formData.full_name}
                                                    onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
                                                    className="w-full p-3 border-2 border-black rounded-lg focus:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] focus:outline-none transition-shadow"
                                                />
                                            </div>
                                            <div>
                                                <label className="block text-sm font-bold mb-2">{t('bio')}</label>
                                                <textarea
                                                    value={formData.bio}
                                                    onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
                                                    rows={3}
                                                    className="w-full p-3 border-2 border-black rounded-lg focus:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] focus:outline-none transition-shadow resize-none"
                                                />
                                            </div>
                                            <div className="flex justify-end gap-3">
                                                <button
                                                    onClick={() => setIsEditing(false)}
                                                    className="px-4 py-2 font-bold border-2 border-transparent hover:bg-gray-100 rounded-lg"
                                                >
                                                    {t('cancel')}
                                                </button>
                                                <button
                                                    onClick={handleSave}
                                                    disabled={saving}
                                                    className="flex items-center gap-2 px-6 py-2 bg-black text-white font-bold border-2 border-black rounded-lg hover:shadow-[4px_4px_0px_0px_rgba(0,0,0,0.2)] hover:-translate-y-1 transition-all"
                                                >
                                                    {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                                                    {t('save_changes')}
                                                </button>
                                            </div>
                                        </div>
                                    )}

                                    {/* User Details Grid */}
                                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 border-2 border-gray-200 rounded-lg">
                                            <Mail className="w-5 h-5 text-gray-500" />
                                            <div className="overflow-hidden">
                                                <div className="text-xs font-bold text-gray-400 uppercase">Email</div>
                                                <div className="text-sm font-medium truncate">{user?.email}</div>
                                            </div>
                                        </div>
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 border-2 border-gray-200 rounded-lg">
                                            <Calendar className="w-5 h-5 text-gray-500" />
                                            <div>
                                                <div className="text-xs font-bold text-gray-400 uppercase">{t('joined')}</div>
                                                <div className="text-sm font-medium">{new Date(profile?.created_at).toLocaleDateString()}</div>
                                            </div>
                                        </div>
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 border-2 border-gray-200 rounded-lg">
                                            <User className="w-5 h-5 text-gray-500" />
                                            <div>
                                                <div className="text-xs font-bold text-gray-400 uppercase">Role</div>
                                                <div className="text-sm font-medium capitalize">{profile?.role}</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Tabs */}
                    <div className="flex gap-4 border-b-4 border-black/10 pb-1 overflow-x-auto">
                        {['overview', 'badges', 'certificates', 'activity'].map((tab) => (
                            <button
                                key={tab}
                                onClick={() => setActiveTab(tab as Tab)}
                                className={`pb-3 px-6 font-black text-lg border-b-4 transition-all whitespace-nowrap flex items-center gap-2 ${activeTab === tab
                                    ? 'border-black text-black translate-y-1'
                                    : 'border-transparent text-gray-400 hover:text-gray-600 hover:border-gray-200'
                                    }`}
                            >
                                {tab === 'overview' && <User className="w-5 h-5" />}
                                {tab === 'badges' && <Award className="w-5 h-5" />}
                                {tab === 'certificates' && <FileText className="w-5 h-5" />}
                                {tab === 'activity' && <Activity className="w-5 h-5" />}
                                {tab === 'certificates' ? tCerts('title') : t(tab === 'activity' ? 'activity_log' : tab)}
                            </button>
                        ))}
                    </div>

                    {/* Content */}
                    <div className="grid gap-8">
                        {activeTab === 'overview' && (
                            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                                {/* Left: XP & Progress */}
                                <div className="lg:col-span-2 space-y-8">
                                    <div className="bg-white border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] rounded-xl p-6">
                                        <h3 className="text-xl font-black mb-6 flex items-center gap-3">
                                            <div className="p-2 bg-yellow-400 border-2 border-black rounded-lg">
                                                <Award className="w-6 h-6 text-black" />
                                            </div>
                                            {t('your_progress')}
                                        </h3>
                                        <XPBar
                                            currentXP={profile?.total_xp || 0}
                                            level={profile?.level || 1}
                                        />
                                    </div>

                                    {/* Categories */}
                                    {categories.length > 0 && (
                                        <div className="bg-white border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] rounded-xl p-6">
                                            <h3 className="text-xl font-black mb-6 flex items-center gap-3">
                                                <div className="p-2 bg-purple-400 border-2 border-black rounded-lg">
                                                    <Tag className="w-6 h-6 text-black" />
                                                </div>
                                                {t('categories')}
                                            </h3>
                                            <div className="flex flex-wrap gap-3">
                                                {categories.map((uc: any) => (
                                                    <span
                                                        key={uc.category_id}
                                                        className="px-4 py-2 rounded-lg text-sm font-bold border-2 bg-white"
                                                        style={{
                                                            borderColor: uc.categories.color,
                                                            color: uc.categories.color,
                                                            boxShadow: `4px 4px 0px 0px ${uc.categories.color}`
                                                        }}
                                                    >
                                                        {uc.categories.name}
                                                    </span>
                                                ))}
                                            </div>
                                        </div>
                                    )}
                                </div>

                                {/* Right: Streaks */}
                                <div>
                                    <div className="bg-white border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] rounded-xl p-6 sticky top-8">
                                        <h3 className="text-xl font-black mb-6 flex items-center gap-3">
                                            <div className="p-2 bg-orange-500 border-2 border-black rounded-lg">
                                                <Activity className="w-6 h-6 text-white" />
                                            </div>
                                            {t('streak_stats')}
                                        </h3>
                                        <StreakCounter
                                            currentStreak={streakData?.current_streak || 0}
                                            longestStreak={streakData?.longest_streak || 0}
                                            lastActivityDate={streakData?.last_activity_date}
                                            variant="minimal"
                                        />
                                    </div>
                                </div>
                            </div>
                        )}

                        {activeTab === 'badges' && (
                            <div className="bg-white border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] rounded-xl p-8">
                                <BadgeCollection />
                            </div>
                        )}

                        {activeTab === 'certificates' && (
                            <div className="bg-white border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] rounded-xl p-8">
                                <h3 className="text-xl font-black mb-6 flex items-center gap-3">
                                    <div className="p-2 bg-green-400 border-2 border-black rounded-lg">
                                        <FileText className="w-6 h-6 text-black" />
                                    </div>
                                    {tCerts('my_certificates')}
                                </h3>
                                {certificates.length > 0 ? (
                                    <div className="grid gap-6">
                                        {certificates.map((cert) => (
                                            <CertificatePDF
                                                key={cert.id}
                                                certificate={cert}
                                                userName={profile?.full_name || 'User'}
                                                courseTitle={cert.course_id}
                                                locale={locale}
                                            />
                                        ))}
                                    </div>
                                ) : (
                                    <div className="text-center py-12">
                                        <FileText className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                                        <p className="text-gray-500 text-lg font-medium">{tCerts('no_certificates')}</p>
                                    </div>
                                )}
                            </div>
                        )}

                        {activeTab === 'activity' && (
                            <div className="bg-white border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] rounded-xl p-8">
                                <h3 className="text-xl font-black mb-6 flex items-center gap-3">
                                    <div className="p-2 bg-blue-400 border-2 border-black rounded-lg">
                                        <Activity className="w-6 h-6 text-black" />
                                    </div>
                                    {t('activity_log')}
                                </h3>
                                <ActivityLog />
                            </div>
                        )}
                    </div>
                </motion.div>
            </div>
        </div>
    );
}
