// Modal de Versões JavaScript

let currentServer = null;
let currentVersions = [];

function openVersionModal(serverType, versions, currentVersion = null) {
    currentServer = serverType;
    currentVersions = versions;
    
    // Configurar título do modal
    const serverNames = {
        'spigot': 'Spigot Server',
        'paper': 'Paper Server',
        'purpur': 'Purpur Server'
    };
    
    document.getElementById('modalTitle').textContent = `Selecionar Versão - ${serverNames[serverType]}`;
    
    // Popular lista de versões
    const versionList = document.getElementById('versionList');
    versionList.innerHTML = '';
    
    versions.forEach(version => {
        const versionItem = document.createElement('div');
        versionItem.className = 'version-item';
        versionItem.textContent = version;
        
        if (currentVersion === version) {
            versionItem.classList.add('selected');
        }
        
        versionItem.addEventListener('click', () => {
            selectVersion(version);
        });
        
        versionList.appendChild(versionItem);
    });
    
    // Mostrar modal
    const modal = document.getElementById('versionModal');
    modal.style.display = 'flex';
    setTimeout(() => {
        modal.classList.add('show');
    }, 10);
}

function closeVersionModal() {
    const modal = document.getElementById('versionModal');
    modal.classList.remove('show');
    setTimeout(() => {
        modal.style.display = 'none';
    }, 300);
}

function selectVersion(version) {
    // Atualizar o select original
    const select = document.querySelector(`.${currentServer} select`);
    if (select) {
        select.value = version;
        // Disparar evento change para atualizar o botão
        select.dispatchEvent(new Event('change'));
    }
    
    // Atualizar o texto do campo de versão
    const versionText = document.querySelector(`.${currentServer} .version-text`);
    if (versionText) {
        versionText.textContent = version;
        versionText.style.color = '#333';
    }
    
    // Atualizar a versão atual do servidor (para Purpur, Paper e Spigot)
    if (currentServer === 'purpur' && window.purpurServer) {
        window.purpurServer.currentVersion = version;
        window.purpurServer.updateDownloadButton();
    } else if (currentServer === 'paper' && window.paperServer) {
        window.paperServer.currentVersion = version;
        window.paperServer.updateDownloadButton();
    } else if (currentServer === 'spigot' && window.spigotServer) {
        window.spigotServer.currentVersion = version;
        window.spigotServer.updateDownloadButton();
    }
    
    // Fechar modal
    closeVersionModal();
}

// Fechar modal ao clicar fora
document.addEventListener('DOMContentLoaded', () => {
    const modal = document.getElementById('versionModal');
    
    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            closeVersionModal();
        }
    });
    
    // Fechar com ESC
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && modal.style.display === 'flex') {
            closeVersionModal();
        }
    });
}); 