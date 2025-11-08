// Paper Server JavaScript
// Arquivo para implementar funcionalidades do servidor Paper

class PaperServer {
    constructor() {
        this.versions = [];
        this.currentVersion = null;
        this.init();
    }

    async init() {
        await this.loadVersions();
        this.setupEventListeners();
    }

    async loadVersions() {
        try {
            // Carregar versões da API do Paper
            const response = await fetch('https://api.papermc.io/v2/projects/paper');
            const data = await response.json();
            
            // Extrair versões disponíveis
            this.versions = data.versions || [];
            
            this.populateVersionSelect();
        } catch (error) {
            console.error('Erro ao carregar versões do Paper:', error);
            this.showError('Erro ao carregar versões');
        }
    }

    populateVersionSelect() {
        const select = document.querySelector('.paper select');
        if (!select) return;

        select.innerHTML = '';
        
        // Adicionar opção padrão
        const defaultOption = document.createElement('option');
        defaultOption.value = '';
        defaultOption.textContent = 'Selecione uma versão';
        select.appendChild(defaultOption);

        // Adicionar versões disponíveis
        this.versions.forEach(version => {
            const option = document.createElement('option');
            option.value = version;
            option.textContent = version;
            select.appendChild(option);
        });
    }

    setupEventListeners() {
        const versionInput = document.querySelector('.paper .version-input');
        const downloadBtn = document.querySelector('.paper-btn');

        if (versionInput) {
            versionInput.addEventListener('click', () => {
                openVersionModal('paper', this.versions, this.currentVersion);
            });
        }

        if (downloadBtn) {
            downloadBtn.addEventListener('click', () => {
                this.downloadServer();
            });
        }
    }

    updateDownloadButton() {
        const downloadBtn = document.querySelector('.paper-btn');
        if (!downloadBtn) return;

        if (this.currentVersion) {
            downloadBtn.disabled = false;
            downloadBtn.innerHTML = `<span class="download-icon">⬇️</span>Download Paper ${this.currentVersion}`;
        } else {
            downloadBtn.disabled = true;
            downloadBtn.innerHTML = `<span class="download-icon">⬇️</span>Selecione uma versão`;
        }
    }

    async downloadServer() {
        if (!this.currentVersion) {
            this.showError('Selecione uma versão primeiro');
            return;
        }

        try {
            console.log(`Iniciando download do Paper ${this.currentVersion} (latest build)`);
            
            // Primeiro, buscar a build mais recente
            const buildsResponse = await fetch(`https://api.papermc.io/v2/projects/paper/versions/${this.currentVersion}/builds`);
            const buildsData = await buildsResponse.json();
            
            if (!buildsData.builds || buildsData.builds.length === 0) {
                throw new Error('Nenhuma build encontrada para esta versão');
            }
            
            // Pegar a build mais recente
            const latestBuild = buildsData.builds[buildsData.builds.length - 1].build;
            
            // URL para download da build mais recente
            const downloadUrl = `https://api.papermc.io/v2/projects/paper/versions/${this.currentVersion}/builds/${latestBuild}/downloads/paper-${this.currentVersion}-${latestBuild}.jar`;
            
            // Criar link de download
            const link = document.createElement('a');
            link.href = downloadUrl;
            link.download = `paper-${this.currentVersion}-${latestBuild}.jar`;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            this.showSuccess(`Download do Paper ${this.currentVersion} (build ${latestBuild}) iniciado!`);
        } catch (error) {
            console.error('Erro no download:', error);
            this.showError('Erro ao fazer download');
        }
    }

    showError(message) {
        console.error(message);
        // TODO: Implementar notificação de erro visual
    }

    showSuccess(message) {
        console.log(message);
        // TODO: Implementar notificação de sucesso visual
    }
}

// Inicializar quando o DOM estiver carregado
document.addEventListener('DOMContentLoaded', () => {
    window.paperServer = new PaperServer();
});
