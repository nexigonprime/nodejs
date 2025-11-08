// Gerenciador de Configurações Avançadas JVM
class AdvancedConfigManager {
    constructor() {
        this.presets = this.getPresets();
        this.currentPreset = null;
        this.allArgs = this.getAllArgs();
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.displayArgs(); // Mostrar todos os argumentos por padrão
    }

    // Obter presets de configuração
    getPresets() {
        return {
            performance: {
                name: '🚀 Performance',
                description: 'Otimizado para máxima performance',
                args: [
                    '-XX:+UseG1GC',
                    '-XX:+UnlockExperimentalVMOptions',
                    '-XX:MaxGCPauseMillis=100',
                    '-XX:+OptimizeStringConcat',
                    '-XX:+UseCompressedOops',
                    '-XX:+UseStringDeduplication',
                    '-XX:+UseFastAccessorMethods',
                    '-XX:+AggressiveOpts'
                ]
            },
            memory: {
                name: '💾 Memória',
                description: 'Otimizado para uso eficiente de memória',
                args: [
                    '-XX:+UseConcMarkSweepGC',
                    '-XX:+UseParNewGC',
                    '-XX:+CMSIncrementalPacing',
                    '-XX:ParallelGCThreads=4',
                    '-XX:+AggressiveOpts',
                    '-XX:+UseCompressedOops',
                    '-XX:+UseStringDeduplication'
                ]
            },
            balanced: {
                name: '⚖️ Equilibrado',
                description: 'Balanço entre performance e estabilidade',
                args: [
                    '-XX:+UseG1GC',
                    '-XX:+UnlockExperimentalVMOptions',
                    '-XX:MaxGCPauseMillis=200',
                    '-XX:+UseCompressedOops',
                    '-XX:+UseStringDeduplication',
                    '-XX:+OptimizeStringConcat'
                ]
            }
        };
    }

    // Obter todos os argumentos disponíveis
    getAllArgs() {
        return [
            { arg: '-XX:+UseG1GC', desc: 'Coletor de lixo G1 (recomendado)' },
            { arg: '-XX:+UnlockExperimentalVMOptions', desc: 'Habilita opções experimentais' },
            { arg: '-XX:MaxGCPauseMillis=100', desc: 'Pausa máxima do GC' },
            { arg: '-XX:+OptimizeStringConcat', desc: 'Otimização de concatenação de strings' },
            { arg: '-XX:+UseCompressedOops', desc: 'Compressão de ponteiros (economia de memória)' },
            { arg: '-XX:+UseStringDeduplication', desc: 'Deduplicação de strings' },
            { arg: '-XX:+UseFastAccessorMethods', desc: 'Métodos de acesso otimizados' },
            { arg: '-XX:+AggressiveOpts', desc: 'Otimizações agressivas' },
            { arg: '-XX:+UseConcMarkSweepGC', desc: 'Coletor CMS (legado)' },
            { arg: '-XX:+UseParNewGC', desc: 'Coletor ParNew' },
            { arg: '-XX:+CMSIncrementalPacing', desc: 'Pacing incremental do CMS' },
            { arg: '-XX:ParallelGCThreads=4', desc: 'Threads paralelas do GC' }
        ];
    }

    // Configurar event listeners
    setupEventListeners() {
        // Event listeners para os botões de preset
        const presetButtons = document.querySelectorAll('.preset-btn');
        presetButtons.forEach(button => {
            button.addEventListener('click', () => {
                const presetName = button.getAttribute('data-preset');
                this.loadPreset(presetName);
            });
        });
    }



    // Exibir argumentos na interface
    displayArgs(argsToShow = null) {
        const display = document.getElementById('jvmArgsDisplay');
        if (!display) return;

        let args = argsToShow || this.allArgs;
        
        display.innerHTML = args.map(item => `
            <div class="jvm-arg-item">
                <span class="jvm-arg">${item.arg}</span>
                <span class="jvm-desc">${item.desc}</span>
            </div>
        `).join('');
    }

    // Carregar preset
    loadPreset(presetName) {
        const preset = this.presets[presetName];
        if (!preset) return;

        // Atualizar estado dos botões
        document.querySelectorAll('.preset-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        
        const activeButton = document.querySelector(`[data-preset="${presetName}"]`);
        if (activeButton) {
            activeButton.classList.add('active');
        }

        // Filtrar argumentos do preset
        const presetArgs = this.allArgs.filter(item => 
            preset.args.includes(item.arg)
        );

        this.currentPreset = presetName;
        this.displayArgs(presetArgs);
        this.showMessage(`Preset "${preset.name}" carregado!`, 'success');
    }

    // Limpar preset (mostrar todos os argumentos)
    clearPreset() {
        document.querySelectorAll('.preset-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        
        this.currentPreset = null;
        this.displayArgs();
        this.showMessage('Mostrando todos os argumentos disponíveis', 'info');
    }

    // Obter argumentos JVM atuais
    getCurrentArgs() {
        if (this.currentPreset) {
            const preset = this.presets[this.currentPreset];
            return preset ? preset.args : [];
        }
        return this.allArgs.map(item => item.arg);
    }

    // Validar argumentos JVM
    validateArgs(args) {
        const validPrefixes = [
            '-XX:', '-X', '-D', '-server', '-client'
        ];

        const invalidArgs = args.filter(arg => {
            const trimmed = arg.trim();
            if (!trimmed) return false;
            
            return !validPrefixes.some(prefix => trimmed.startsWith(prefix));
        });

        if (invalidArgs.length > 0) {
            this.showMessage(`Argumentos inválidos detectados: ${invalidArgs.join(', ')}`, 'warning');
            return false;
        }

        return true;
    }

    // Gerar script com argumentos JVM
    generateScriptWithJVM(xms, xmx, os, jvmArgs = null) {
        const args = jvmArgs || this.getCurrentArgs();
        
        if (!this.validateArgs(args)) {
            return null;
        }

        const xmxMB = parseInt(xmx) * 1024;
        const xmsMB = parseInt(xms) * 1024;

        let script;
        if (os === 'windows') {
            script = `@echo off
title Minecraft Server
REM Configurações de RAM
set XMX=${xmxMB}M
set XMS=${xmsMB}M
REM Argumentos JVM
set JVM_ARGS=${args.join(' ')}
REM Iniciar servidor
java %JVM_ARGS% -Xmx%XMX% -Xms%XMS% -jar server.jar nogui
pause`;
        } else {
            script = `#!/bin/bash
# Configurações de RAM
XMX=${xmxMB}M
XMS=${xmsMB}M
# Argumentos JVM
JVM_ARGS="${args.join(' ')}"
# Iniciar servidor
java $JVM_ARGS -Xmx$XMX -Xms$XMS -jar server.jar nogui
echo "Servidor parado. Pressione Enter para sair..."
read`;
        }

        return script;
    }

    // Mostrar mensagem
    showMessage(message, type = 'info') {
        // Implementar sistema de notificação se necessário
        console.log(`${type}: ${message}`);
    }

    // Exportar configuração
    exportConfig() {
        const config = {
            args: this.getCurrentArgs(),
            presets: this.presets,
            exportDate: new Date().toISOString()
        };

        const blob = new Blob([JSON.stringify(config, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `jvm-config-${new Date().toISOString().split('T')[0]}.json`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
    }

    // Importar configuração
    importConfig(file) {
        const reader = new FileReader();
        reader.onload = (e) => {
            try {
                const config = JSON.parse(e.target.result);
                if (config.args) {
                    document.getElementById('jvmArgs').value = config.args.join('\n');
                    this.saveConfig();
                    this.showMessage('Configuração importada com sucesso!', 'success');
                }
            } catch (error) {
                this.showMessage('Erro ao importar configuração', 'error');
            }
        };
        reader.readAsText(file);
    }
}

// Funções globais
function loadPreset(presetName) {
    if (window.advancedConfigManager) {
        window.advancedConfigManager.loadPreset(presetName);
    }
}

// Função para copiar argumentos JVM
function copyJVMArgs() {
    let jvmArgs = [];
    
    // Se há um preset ativo, copiar apenas os argumentos do preset
    if (window.advancedConfigManager && window.advancedConfigManager.currentPreset) {
        const preset = window.advancedConfigManager.presets[window.advancedConfigManager.currentPreset];
        jvmArgs = preset.args;
    } else {
        // Se não há preset ativo, copiar todos os argumentos
        jvmArgs = window.advancedConfigManager.allArgs.map(item => item.arg);
    }
    
    const argsText = jvmArgs.join(' ');
    
    navigator.clipboard.writeText(argsText).then(() => {
        // Mostrar feedback visual
        const copyBtn = document.querySelector('.copy-jvm-btn');
        const originalText = copyBtn.innerHTML;
        
        copyBtn.innerHTML = '<span class="copy-icon">✅</span>Copiado!';
        copyBtn.style.background = 'linear-gradient(135deg, #10b981, #059669)';
        
        setTimeout(() => {
            copyBtn.innerHTML = originalText;
            copyBtn.style.background = 'linear-gradient(135deg, #8b5cf6, #7c3aed)';
        }, 2000);
        
        console.log('Argumentos JVM copiados para a área de transferência!');
    }).catch(err => {
        console.error('Erro ao copiar argumentos JVM:', err);
    });
}

// Inicializar quando a página carregar
document.addEventListener('DOMContentLoaded', () => {
    window.advancedConfigManager = new AdvancedConfigManager();
}); 