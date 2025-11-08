// Spigot Server JavaScript
// Arquivo para implementar funcionalidades do servidor Spigot

class SpigotServer {
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
            // Carregar versões do Spigot (usando uma lista mais confiável)
            // Como a API do Spigot pode ser instável, vou usar versões conhecidas
            this.versions = [
                '1.21.5',
                '1.21.4',
                '1.21.3',
                '1.21.2',
                '1.21.1',
                '1.21',
                '1.20.6',
                '1.20.5',
                '1.20.4',
                '1.20.3',
                '1.20.2',
                '1.20.1',
                '1.19.4',
                '1.19.3',
                '1.19.2',
                '1.19.1',
                '1.18.2',
                '1.18.1',
                '1.17.1',
                '1.16.5',
                '1.16.4',
                '1.16.3',
                '1.16.2',
                '1.16.1',
                '1.15.2',
                '1.15.1',
                '1.15',
                '1.14.4',
                '1.14.3',
                '1.14.2',
                '1.14.1'
            ];
            
            this.populateVersionSelect();
        } catch (error) {
            console.error('Erro ao carregar versões do Spigot:', error);
            this.showError('Erro ao carregar versões');
        }
    }

    populateVersionSelect() {
        const select = document.querySelector('.spigot select');
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
        const versionInput = document.querySelector('.spigot .version-input');
        const downloadBtn = document.querySelector('.spigot-btn');

        if (versionInput) {
            versionInput.addEventListener('click', () => {
                openVersionModal('spigot', this.versions, this.currentVersion);
            });
        }

        if (downloadBtn) {
            downloadBtn.addEventListener('click', () => {
                this.downloadServer();
            });
        }
    }

    updateDownloadButton() {
        const downloadBtn = document.querySelector('.spigot-btn');
        if (!downloadBtn) return;

        if (this.currentVersion) {
            downloadBtn.disabled = false;
            downloadBtn.innerHTML = `<span class="download-icon">⬇️</span>Download Spigot ${this.currentVersion}`;
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
            console.log(`Iniciando download do Spigot ${this.currentVersion}`);
            
            // URL para download do Spigot (BuildTools)
            const downloadUrl = `https://cdn.getbukkit.org/spigot/spigot-${this.currentVersion}.jar`;
            
            // Criar link de download
            const link = document.createElement('a');
            link.href = downloadUrl;
            link.download = `spigot-${this.currentVersion}.jar`;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            this.showSuccess(`Download do Spigot ${this.currentVersion} iniciado!`);
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
    window.spigotServer = new SpigotServer();
});
