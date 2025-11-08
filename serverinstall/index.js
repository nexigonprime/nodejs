const express = require('express');
const path = require('path');

const app = express();
const PORT = 3001;

// Servir arquivos estáticos (CSS, JS, imagens, etc.)
app.use(express.static(__dirname));

// Rota principal
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Inicia o servidor
app.listen(PORT, () => {
    console.log(`Servidor rodando em http://localhost:${PORT}`);
});