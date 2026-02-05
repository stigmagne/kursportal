export type UserGroup = {
    value: string;
    label: string;
    desc: string;
};

export const USER_GROUPS: UserGroup[] = [
    { value: 'sibling', label: 'Søsken', desc: 'For voksne søsken' },
    { value: 'parent', label: 'Foreldre', desc: 'For foreldre/foresatte' },
    { value: 'team-member', label: 'Teammedlem', desc: 'For ansatte i team' },
    { value: 'team-leader', label: 'Teamleder', desc: 'For ledere og mellomledere' },
    { value: 'construction_worker', label: 'Håndverker', desc: 'For fagarbeidere i bygg' },
    { value: 'site_manager', label: 'Bas/Byggeleder', desc: 'For byggledelse' },
];
