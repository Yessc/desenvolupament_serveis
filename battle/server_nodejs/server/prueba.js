'use strict';

const { loadMultiplayerLevel } = require('./multiplayerLevelData.js');

class GameLogic {
    constructor() {
        this.players = new Map();
        this.levelData = loadMultiplayerLevel();

        // Cargar gemas del JSON
        this.gems = (this.levelData.sprites || [])
            .filter(s => s.type === "Gema")
            .map((s, index) => ({
                id: `gem-${index}`,
                x: s.x,
                y: s.y,
                width: s.width || 15,
                height: s.height || 14,
                collected: false,
                points: 10
            }));

        this.phase = 'waiting';
        this.lastUpdateTimestamp = Date.now();
    }

    // --- MÉTODOS REQUERIDOS POR app.js ---

    addClient(id, name) {
        this.players.set(id, {
            id,
            name: name || 'Player',
            x: 100,
            y: 100,
            width: 20,
            height: 20,
            score: 0,
            gemsCollected: 0,
            direction: 'none',
            moving: false,
            facing: 'down'
        });
    }

    removeClient(id) {
        this.players.delete(id);
    }

    // app.js:82
    getSnapshotState() {
        return {
            phase: this.phase,
            gems: this.gems.filter(g => !g.collected)
        };
    }

    // app.js:129
    consumeSnapshotState() {
        return this.getSnapshotState();
    }

    // app.js:159 - ESTA ES LA QUE FALTABA
    getGameplayStateForPlayer(id, options = {}) {
        const player = this.players.get(id);
        return {
            self: player,
            others: options.includeOtherPlayers
                ? Array.from(this.players.values()).filter(p => p.id !== id)
                : [],
            gems: options.includeGems
                ? this.gems.filter(g => !g.collected)
                : []
        };
    }

    // app.js:106
    updateGame(fps) {
        const dt = 1 / (fps || 60);

        this.players.forEach(player => {
            let vx = 0, vy = 0;
            if (player.direction.includes('up')) vy = -120;
            if (player.direction.includes('down')) vy = 120;
            if (player.direction.includes('left')) vx = -120;
            if (player.direction.includes('right')) vx = 120;

            if (vx !== 0 && vy !== 0) { vx *= 0.707; vy *= 0.707; }

            player.x += vx * dt;
            player.y += vy * dt;

            // Colisión con gemas
            for (const gem of this.gems) {
                if (!gem.collected) {
                    if (player.x < gem.x + gem.width &&
                        player.x + player.width > gem.x &&
                        player.y < gem.y + gem.height &&
                        player.y + player.height > gem.y) {
                        gem.collected = true;
                        player.score += 10;
                        player.gemsCollected++;
                    }
                }
            }
        });

        if (this.phase === 'waiting' && this.players.size > 0) {
            this.phase = 'playing';
        }
    }

    handleMessage(id, msg) {
        try {
            const data = JSON.parse(msg);
            if (data.type === 'input') {
                const player = this.players.get(id);
                if (player) {
                    player.direction = data.direction || 'none';
                    player.moving = player.direction !== 'none';
                    if (player.moving) player.facing = player.direction;
                }
            }
            return true;
        } catch (e) {
            return false;
        }
    }

    restartToWaitingRoom() {
        this.phase = 'waiting';
        this.gems.forEach(g => g.collected = false);
        this.players.forEach(p => {
            p.score = 0;
            p.gemsCollected = 0;
        });
    }
}

module.exports = GameLogic;