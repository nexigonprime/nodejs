// Gerenciador de Plugins Recomendados
class PluginsManager {
    constructor() {
        this.plugins = this.getPlugins();
        this.downloadHistory = this.loadDownloadHistory();
        this.init();
    }

    init() {
        this.renderPlugins();
    }

    // Obter lista de plugins
    getPlugins() {
        return {
            protection: {
                name: '🛡️ Proteção',
                plugins: [
                    {
                        name: 'WorldGuard',
                        description: 'Proteção de áreas e regiões',
                        version: '7.0.9',
                        compatibility: ['spigot', 'paper', 'purpur'],
                        downloadUrl: 'https://dev.bukkit.org/projects/worldguard/files',
                        configUrl: 'https://worldguard.enginehub.org/en/latest/',
                        essential: true
                    },
                    {
                        name: 'CoreProtect',
                        description: 'Log de ações e rollback',
                        version: '21.0',
                        compatibility: ['spigot', 'paper', 'purpur'],
                        downloadUrl: 'https://www.spigotmc.org/resources/coreprotect.8631/',
                        configUrl: 'https://docs.coreprotect.com/',
                        essential: true
                    },
                    {
                        name: 'LocketteX',
                        description: 'Proteção de baús e portas',
                        version: '2.10.0',
                        compatibility: ['spigot', 'paper', 'purpur'],
                        downloadUrl: 'https://www.spigotmc.org/resources/lockettex.10684/',
                        configUrl: 'https://github.com/Dutchy61/LocketteX/wiki',
                        essential: false
                    }
                ]
            },
            economy: {
                name: '💰 Economia',
                plugins: [
                    {
                        name: 'Vault',
                        description: 'Sistema de economia base',
                        version: '1.7.3',
                        compatibility: ['spigot', 'paper', 'purpur'],
                        downloadUrl: 'https://www.spigotmc.org/resources/vault.34315/',
                        configUrl: 'https://github.com/MilkBowl/Vault/wiki',
                        essential: true
                    },
                    {
                        name: 'EssentialsX',
                        description: 'Comandos básicos e economia',
                        version: '2.20.1',
                        compatibility: ['spigot', 'paper', 'purpur'],
                        downloadUrl: 'https://essentialsx.net/downloads.html',
                        configUrl: 'https://essentialsx.net/wiki/',
                        essential: true
                    },
                    {
                        name: 'Shopkeepers',
                        description: 'NPCs vendedores',
                        version: '3.1.0',
                        compatibility: ['spigot', 'paper', 'purpur'],
                        downloadUrl: 'https://www.spigotmc.org/resources/shopkeepers.8074/',
                        configUrl: 'https://github.com/Shopkeepers/Shopkeepers/wiki',
                        essential: false
                    }
                ]
            },
            fun: {
                name: '🎮 Diversão',
                plugins: [
                    {
                        name: 'WorldEdit',
                        description: 'Edição de mundo',
                        version: '7.2.15',
                        compatibility: ['spigot', 'paper', 'purpur'],
                        downloadUrl: 'https://dev.bukkit.org/projects/worldedit/files',
                        configUrl: 'https://worldedit.enginehub.org/en/latest/',
                        essential: false
                    },
                    {
                        name: 'Multiverse-Core',
                        description: 'Múltiplos mundos',
                        version: '4.3.1',
                        compatibility: ['spigot', 'paper', 'purpur'],
                        downloadUrl: 'https://dev.bukkit.org/projects/multiverse-core/files',
                        configUrl: 'https://github.com/Multiverse/Multiverse-Core/wiki',
                        essential: false
                    },
                    {
                        name: 'LuckPerms',
                        description: 'Sistema de permissões',
                        version: '5.4.30',
                        compatibility: ['spigot', 'paper', 'purpur'],
                        downloadUrl: 'https://luckperms.net/download',
                        configUrl: 'https://luckperms.net/wiki/',
                        essential: true
                    }
                ]
            }
        };
    }

    // Carregar histórico de downloads de plugins
    loadDownloadHistory() {
        const saved = localStorage.getItem('pluginDownloadHistory');
        return saved ? JSON.parse(saved) : [];
    }

    // Salvar histórico de downloads
    saveDownloadHistory() {
        localStorage.setItem('pluginDownloadHistory', JSON.stringify(this.downloadHistory));
    }

    // Renderizar plugins na página
    renderPlugins() {
        const pluginCategories = document.querySelectorAll('.plugin-category');
        
        pluginCategories.forEach(category => {
            const categoryName = this.getCategoryName(category);
            const plugins = this.plugins[categoryName];
            
            if (plugins) {
                const pluginList = category.querySelector('.plugin-list');
                if (pluginList) {
                    pluginList.innerHTML = plugins.plugins.map(plugin => `
                        <div class="plugin-item">
                            <div class="plugin-info">
                                <span class="plugin-name">${plugin.name}</span>
                                <span class="plugin-version">v${plugin.version}</span>
                                <span class="plugin-desc">${plugin.description}</span>
                                <div class="plugin-compatibility">
                                    ${this.getCompatibilityIcons(plugin.compatibility)}
                                </div>
                            </div>
                            <div class="plugin-actions">
                                <button class="plugin-download-btn" onclick="pluginsManager.downloadPlugin('${plugin.name}')">
                                    <span class="download-icon">⬇️</span>
                                    Download
                                </button>
                                <button class="plugin-info-btn" onclick="pluginsManager.showPluginInfo('${plugin.name}')">
                                    <span class="info-icon">ℹ️</span>
                                    Info
                                </button>
                            </div>
                        </div>
                    `).join('');
                }
            }
        });
    }

    // Obter nome da categoria
    getCategoryName(categoryElement) {
        const title = categoryElement.querySelector('h4');
        if (title) {
            const text = title.textContent;
            if (text.includes('Proteção')) return 'protection';
            if (text.includes('Economia')) return 'economy';
            if (text.includes('Diversão')) return 'fun';
        }
        return null;
    }

    // Obter ícones de compatibilidade
    getCompatibilityIcons(compatibility) {
        const icons = {
            'spigot': '⛏️',
            'paper': '📄',
            'purpur': '⚪'
        };
        
        return compatibility.map(server => 
            `<span class="compatibility-icon" title="${server}">${icons[server]}</span>`
        ).join('');
    }

    // Download de plugin
    downloadPlugin(pluginName) {
        const plugin = this.findPlugin(pluginName);
        if (!plugin) return;

        // Adicionar ao histórico
        this.addToHistory(plugin);

        // Abrir link de download
        window.open(plugin.downloadUrl, '_blank');
        
        this.showMessage(`Download de ${plugin.name} iniciado!`, 'success');
    }

    // Mostrar informações do plugin
    showPluginInfo(pluginName) {
        const plugin = this.findPlugin(pluginName);
        if (!plugin) return;

        const info = `
📦 ${plugin.name} v${plugin.version}

📝 Descrição:
${plugin.description}

🔧 Compatibilidade:
${plugin.compatibility.map(server => `• ${server}`).join('\n')}

⭐ ${plugin.essential ? 'Plugin essencial' : 'Plugin opcional'}

📚 Documentação: ${plugin.configUrl}
        `;

        alert(info);
    }

    // Encontrar plugin por nome
    findPlugin(pluginName) {
        for (const category in this.plugins) {
            const plugin = this.plugins[category].plugins.find(p => p.name === pluginName);
            if (plugin) return plugin;
        }
        return null;
    }

    // Adicionar ao histórico
    addToHistory(plugin) {
        const download = {
            name: plugin.name,
            version: plugin.version,
            category: this.getPluginCategory(plugin.name),
            timestamp: new Date().toISOString(),
            date: new Date().toLocaleString('pt-BR')
        };

        this.downloadHistory.unshift(download);
        
        // Manter apenas os últimos 50 downloads
        if (this.downloadHistory.length > 50) {
            this.downloadHistory = this.downloadHistory.slice(0, 50);
        }

        this.saveDownloadHistory();
    }

    // Obter categoria do plugin
    getPluginCategory(pluginName) {
        for (const category in this.plugins) {
            const plugin = this.plugins[category].plugins.find(p => p.name === pluginName);
            if (plugin) return category;
        }
        return 'unknown';
    }

    // Gerar lista de plugins essenciais
    getEssentialPlugins() {
        const essential = [];
        for (const category in this.plugins) {
            const essentialPlugins = this.plugins[category].plugins.filter(p => p.essential);
            essential.push(...essentialPlugins);
        }
        return essential;
    }

    // Gerar configuração de plugins
    generatePluginConfig(serverType) {
        const compatiblePlugins = [];
        
        for (const category in this.plugins) {
            const plugins = this.plugins[category].plugins.filter(p => 
                p.compatibility.includes(serverType)
            );
            compatiblePlugins.push(...plugins);
        }

        return compatiblePlugins;
    }

    // Mostrar mensagem
    showMessage(message, type = 'info') {
        // Implementar sistema de notificação se necessário
        console.log(`${type}: ${message}`);
    }

    // Exportar lista de plugins
    exportPluginList() {
        const data = {
            exportDate: new Date().toISOString(),
            plugins: this.plugins,
            downloadHistory: this.downloadHistory
        };

        const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `plugins-list-${new Date().toISOString().split('T')[0]}.json`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
    }
}

// Inicializar quando a página carregar
let pluginsManager;
document.addEventListener('DOMContentLoaded', () => {
    pluginsManager = new PluginsManager();
}); 