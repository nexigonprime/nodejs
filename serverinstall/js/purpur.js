// Purpur Server JavaScript
// Arquivo para implementar funcionalidades do servidor Purpur

class PurpurServer {
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
            // Carregar versões da API do Purpur
            const response = await fetch('https://api.purpurmc.org/v2/purpur');
            const data = await response.json();
            
            // Extrair versões disponíveis
            this.versions = data.versions || [];
            
            this.populateVersionSelect();
        } catch (error) {
            console.error('Erro ao carregar versões do Purpur:', error);
            this.showError('Erro ao carregar versões');
        }
    }

    populateVersionSelect() {
        const select = document.querySelector('.purpur select');
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
        const versionInput = document.querySelector('.purpur .version-input');
        const downloadBtn = document.querySelector('.purpur-btn');

        if (versionInput) {
            versionInput.addEventListener('click', () => {
                openVersionModal('purpur', this.versions, this.currentVersion);
            });
        }

        if (downloadBtn) {
            downloadBtn.addEventListener('click', () => {
                this.downloadServer();
            });
        }
    }

    updateDownloadButton() {
        const downloadBtn = document.querySelector('.purpur-btn');
        if (!downloadBtn) return;

        if (this.currentVersion) {
            downloadBtn.disabled = false;
            downloadBtn.innerHTML = `<span class="download-icon">⬇️</span>Download Purpur ${this.currentVersion}`;
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
            console.log(`Iniciando download do Purpur ${this.currentVersion} (latest build)`);
            
            // URL para download da build mais recente
            const downloadUrl = `https://api.purpurmc.org/v2/purpur/${this.currentVersion}/latest/download`;
            
            // Criar link de download
            const link = document.createElement('a');
            link.href = downloadUrl;
            link.download = `purpur-${this.currentVersion}.jar`;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            this.showSuccess(`Download do Purpur ${this.currentVersion} iniciado!`);
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
    window.purpurServer = new PurpurServer();
}); 