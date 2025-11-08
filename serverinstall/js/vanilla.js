// Vanilla Server JavaScript
// Arquivo para implementar funcionalidades do servidor Vanilla

class VanillaServer {
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
            // Carregar versões da API oficial da Mojang
            const response = await fetch('https://launchermeta.mojang.com/mc/game/version_manifest.json');
            const data = await response.json();
            
            // Extrair versões disponíveis (mais recentes primeiro)
            this.versions = data.versions
                .filter(version => version.type === 'release')
                .map(version => ({
                    id: version.id,
                    type: version.type,
                    url: version.url,
                    releaseTime: version.releaseTime
                }))
                .slice(0, 30); // Limitar a 30 versões mais recentes
            
            this.populateVersionSelect();
        } catch (error) {
            console.error('Erro ao carregar versões do Vanilla:', error);
            this.showError('Erro ao carregar versões');
        }
    }

    populateVersionSelect() {
        const select = document.querySelector('.vanilla .version-select');
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
            option.value = version.id;
            option.textContent = `${version.id} (${new Date(version.releaseTime).toLocaleDateString()})`;
            select.appendChild(option);
        });
    }

    setupEventListeners() {
        const versionSelect = document.querySelector('.vanilla .version-select');
        const downloadBtn = document.querySelector('.vanilla-btn');

        if (versionSelect) {
            versionSelect.addEventListener('change', (e) => {
                this.currentVersion = e.target.value;
                this.updateDownloadButton();
            });
        }

        if (downloadBtn) {
            downloadBtn.addEventListener('click', () => {
                this.downloadServer();
            });
        }
    }

    updateDownloadButton() {
        const downloadBtn = document.querySelector('.vanilla-btn');
        if (!downloadBtn) return;

        if (this.currentVersion) {
            downloadBtn.disabled = false;
            downloadBtn.innerHTML = `<span class="download-icon">⬇️</span>Download Vanilla ${this.currentVersion}`;
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
            console.log(`Iniciando download do Vanilla ${this.currentVersion}`);
            
            // Buscar informações detalhadas da versão
            const versionInfo = this.versions.find(v => v.id === this.currentVersion);
            if (!versionInfo) {
                throw new Error('Versão não encontrada');
            }

            // Buscar URL do servidor
            const versionResponse = await fetch(versionInfo.url);
            const versionData = await versionResponse.json();
            
            const serverUrl = versionData.downloads.server?.url;
            if (!serverUrl) {
                throw new Error('URL do servidor não encontrada');
            }
            
            // Criar link de download
            const link = document.createElement('a');
            link.href = serverUrl;
            link.download = `minecraft_server.${this.currentVersion}.jar`;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            this.showSuccess(`Download do Vanilla ${this.currentVersion} iniciado!`);
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
    window.vanillaServer = new VanillaServer();
}); 