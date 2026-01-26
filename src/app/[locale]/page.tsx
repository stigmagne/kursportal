'use client';

import { motion } from 'framer-motion';
import { ArrowRight, BookOpen, Shield, Lock, GraduationCap, LucideIcon } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { useTranslations } from 'next-intl';

export default function Home() {
  const t = useTranslations('Home');

  return (
    <div className="flex flex-col min-h-full">
      {/* Hero Section */}
      <section className="flex-1 flex flex-col items-center justify-center text-center px-4 sm:px-6 lg:px-8 py-20 relative overflow-hidden">

        {/* Background Gradients */}
        <div className="absolute inset-0 -z-10 opacity-30">
          <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary/30 rounded-full blur-3xl" />
          <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-purple-500/30 rounded-full blur-3xl" />
        </div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="max-w-4xl mx-auto space-y-8"
        >
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-secondary/80 backdrop-blur-sm border border-border text-sm font-medium text-secondary-foreground">
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
            </span>
            {t('new_courses')}
          </div>

          <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight text-foreground">
            {t('hero_title_1')} <span className="text-primary bg-clip-text">{t('hero_title_highlight')}</span>.
            <br />
            {t('hero_title_2')} <span className="text-purple-600">{t('hero_title_highlight_2')}</span>.
          </h1>

          <p className="text-xl text-muted-foreground max-w-2xl mx-auto leading-relaxed">
            {t('hero_subtitle')}
          </p>

          <div className="flex flex-wrap items-center justify-center gap-4 pt-4">
            <Link href="/courses" className="px-8 py-4 rounded-xl bg-primary text-primary-foreground font-semibold text-lg hover:opacity-90 transition-all flex items-center gap-2 shadow-lg shadow-primary/25">
              {t('start_learning')} <ArrowRight className="w-5 h-5" />
            </Link>
            <Link href="/journal" className="px-8 py-4 rounded-xl bg-secondary text-secondary-foreground font-semibold text-lg hover:bg-secondary/80 transition-all border border-border flex items-center gap-2">
              <Shield className="w-5 h-5" /> {t('private_journal')}
            </Link>
          </div>
        </motion.div>
      </section>

      {/* Feature Grid */}
      <section className="py-24 bg-secondary/30 border-t border-border/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <FeatureCard
              icon={BookOpen}
              title={t('features.interactive_courses')}
              description={t('features.interactive_courses_desc')}
              delay={0.2}
            />
            <FeatureCard
              icon={GraduationCap}
              title={t('features.smart_quizzes')}
              description={t('features.smart_quizzes_desc')}
              delay={0.4}
            />
            <FeatureCard
              icon={Lock}
              title={t('features.zk_journal')}
              description={t('features.zk_journal_desc')}
              delay={0.6}
            />
          </div>
        </div>
      </section>
    </div>
  );
}

function FeatureCard({ icon: Icon, title, description, delay }: { icon: LucideIcon, title: string, description: string, delay: number }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ delay, duration: 0.5 }}
      className="p-8 rounded-2xl glass border border-white/10 hover:border-primary/20 hover:shadow-xl transition-all group"
    >
      <div className="w-12 h-12 bg-primary/10 rounded-xl flex items-center justify-center text-primary mb-6 group-hover:scale-110 transition-transform">
        <Icon className="w-6 h-6" />
      </div>
      <h3 className="text-xl font-bold mb-3">{title}</h3>
      <p className="text-muted-foreground leading-relaxed">{description}</p>
    </motion.div>
  )
}
