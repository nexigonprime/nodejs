// Inicializador de Script JavaScript

let selectedOS = 'windows'; // Padrão

function selectOS(os) {
    selectedOS = os;
    
    // Atualizar botões
    document.querySelectorAll('.os-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector(`[data-os="${os}"]`).classList.add('active');
}

function generateStartupScript() {
    const xmx = document.getElementById('xmx').value;
    const xms = document.getElementById('xms').value;
    
    // Validação
    if (!xmx || !xms) {
        alert('Por favor, preencha os valores de RAM (XMS e XMX)');
        return;
    }
    
    if (parseInt(xms) > parseInt(xmx)) {
        alert('XMS não pode ser maior que XMX');
        return;
    }
    
    // Converter GB para MB
    const xmxMB = parseInt(xmx) * 1024;
    const xmsMB = parseInt(xms) * 1024;
    
    // Gerar script baseado no SO selecionado
    let script;
    
    if (selectedOS === 'windows') {
        script = `@echo off
title Minecraft Server

REM Configurações de RAM
set XMX=${xmxMB}M
set XMS=${xmsMB}M

REM Iniciar servidor
java -Xmx%XMX% -Xms%XMS% -jar server.jar nogui

pause`;
    } else {
        script = `#!/bin/bash

# Configurações de RAM
XMX=${xmxMB}M
XMS=${xmsMB}M

# Iniciar servidor
java -Xmx$XMX -Xms$XMS -jar server.jar nogui

echo "Servidor parado. Pressione Enter para sair..."
read`;
    }
    
    // Mostrar script gerado
    document.getElementById('startupScript').textContent = script;
    document.getElementById('scriptOutput').style.display = 'block';
    
    // Scroll para o script
    document.getElementById('scriptOutput').scrollIntoView({ 
        behavior: 'smooth' 
    });
}

function copyScript() {
    const scriptText = document.getElementById('startupScript').textContent;
    
    navigator.clipboard.writeText(scriptText).then(() => {
        // Feedback visual
        const copyBtn = document.querySelector('.copy-btn');
        const originalText = copyBtn.innerHTML;
        
        copyBtn.innerHTML = '<span class="copy-icon">✅</span>Copiado!';
        copyBtn.style.background = '#059669';
        
        setTimeout(() => {
            copyBtn.innerHTML = originalText;
            copyBtn.style.background = '#10b981';
        }, 2000);
        
    }).catch(err => {
        console.error('Erro ao copiar: ', err);
        alert('Erro ao copiar script. Tente selecionar e copiar manualmente.');
    });
}

function downloadScript() {
    const scriptText = document.getElementById('startupScript').textContent;
    const selectedOS = document.querySelector('.os-btn.active').dataset.os;
    
    // Determinar extensão do arquivo
    const extension = selectedOS === 'windows' ? 'bat' : 'sh';
    const filename = `startup-script.${extension}`;
    
    // Criar blob e link de download
    const blob = new Blob([scriptText], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    // Limpar URL
    URL.revokeObjectURL(url);
    
    // Feedback visual
    const downloadBtn = document.querySelector('.download-btn-script');
    const originalText = downloadBtn.innerHTML;
    
    downloadBtn.innerHTML = '<span class="download-icon">✅</span>Baixado!';
    downloadBtn.style.background = '#059669';
    
    setTimeout(() => {
        downloadBtn.innerHTML = originalText;
        downloadBtn.style.background = '#3b82f6';
    }, 2000);
}

// Validação em tempo real
document.addEventListener('DOMContentLoaded', () => {
    const xmxInput = document.getElementById('xmx');
    const xmsInput = document.getElementById('xms');
    
    // Validação XMX
    xmxInput.addEventListener('input', () => {
        const value = parseInt(xmxInput.value);
        if (value > 32) {
            xmxInput.value = 32;
        }
    });
    
    // Validação XMS
    xmsInput.addEventListener('input', () => {
        const value = parseInt(xmsInput.value);
        if (value > 16) {
            xmsInput.value = 16;
        }
    });
}); 