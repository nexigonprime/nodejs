// Gerenciador de Tema JavaScript

// Verificar tema salvo no localStorage
function getCurrentTheme() {
    return localStorage.getItem('theme') || 'light';
}

// Aplicar tema
function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('theme', theme);
    
    // Atualizar ícone
    const themeIcon = document.getElementById('themeIcon');
    if (themeIcon) {
        themeIcon.textContent = theme === 'dark' ? '☀️' : '🌙';
    }
}

// Toggle de tema
function toggleTheme() {
    const currentTheme = getCurrentTheme();
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    
    applyTheme(newTheme);
    
    // Animação do ícone
    const themeIcon = document.getElementById('themeIcon');
    if (themeIcon) {
        themeIcon.style.transform = 'rotate(360deg)';
        setTimeout(() => {
            themeIcon.style.transform = 'rotate(0deg)';
        }, 300);
    }
}

// Inicializar tema quando a página carregar
document.addEventListener('DOMContentLoaded', () => {
    const savedTheme = getCurrentTheme();
    applyTheme(savedTheme);
});

// Detectar preferência do sistema
function detectSystemTheme() {
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
        return 'dark';
    }
    return 'light';
}

// Aplicar tema do sistema se não houver preferência salva
if (!localStorage.getItem('theme')) {
    const systemTheme = detectSystemTheme();
    applyTheme(systemTheme);
} 