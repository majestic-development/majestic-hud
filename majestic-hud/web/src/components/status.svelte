<script lang="ts">
    import { fade } from 'svelte/transition';
    import { STATS } from '@stores/stores';
    import { ReceiveEvent } from '@utils/eventsHandlers';
    let visible: boolean = false;
    let health: number = 47;
    let armor: number = 10;
    let talking: boolean = false;
    let talkingOnRadio: boolean = false;
    let onRadio: boolean = false;
    let onPhone: boolean = false;
    let audioRange: number = 0;
    let stats: {[key:string]: number} = {
        hunger: 90,
        thirst: 50,
        stress: 10,
    }
    let statOrder: Array<string> = ['hunger', 'thirst', 'stress']
    ReceiveEvent('updateStats', (data: {showing: boolean, health: number, armor: number, isTalking: boolean, talkingOnRadio: boolean, onRadio: boolean, onPhone: boolean, voiceRange: number, stats: {[key:string]: number}} ): void =>{
        visible = data.showing;
        health = data.health;
        armor = data.armor;
        talking = data.isTalking;
        talkingOnRadio = data.talkingOnRadio;
        onRadio = data.onRadio;
        onPhone = data.onPhone;
        audioRange = data.voiceRange;
        stats = data.stats;
    });
</script>
{#if (visible)}
    <div class="leftDiv" transition:fade={{ duration: 100 }}>
        <div class="barsWrapper">
            <div class="wasteWrapper">
                {#if (armor > 0)}
                    <div class="barWrapper">
                        <i class="fa-solid fa-shield icon"></i>
                        <span class="barTxt" style="color: #2489db;">{armor}</span>
                        <div class="armorBarWrapper">
                            <div class="armorBarBase">
                                <div class="armorBarPill"></div>
                                <div class="armorBarPill"></div>
                                <div class="armorBarPill"></div>
                                <div class="armorBarPill"></div>
                                <div class="armorBarPill"></div>
                            </div>
                            <div class="armorBar" style="width: {armor}%;">
                                <div class="armorBarBase">
                                    <div class="armorBarPill" style="background-color: #2489db; box-shadow: 0 0 0.5vh #2489db; "></div>
                                    <div class="armorBarPill" style="background-color: #2489db; box-shadow: 0 0 0.5vh #2489db; "></div>
                                    <div class="armorBarPill" style="background-color: #2489db; box-shadow: 0 0 0.5vh #2489db; "></div>
                                    <div class="armorBarPill" style="background-color: #2489db; box-shadow: 0 0 0.5vh #2489db; "></div>
                                    <div class="armorBarPill" style="background-color: #2489db; box-shadow: 0 0 0.5vh #2489db; "></div>
                                </div>
                            </div>
                        </div>
                    </div>
                {/if}
                <div class="barWrapper">
                    <i class="fa-solid fa-heart icon" style="{health==0 && 'color:red;'}"></i>
                    <span class="barTxt" style="{health==0 && 'color:red;'}">{health}</span>
                    <div class="barBase" style="{health==0 && 'box-shadow: 0 0 1vh red;'}">
                        <div class="healthbar" style="width:{health}%"></div>
                    </div>
                </div>
                <div class="statWrapper">
                    {#each statOrder as stat}
                        {#if (stats[stat] && $STATS[stat] && $STATS[stat].hide != stats[stat])}
                            <div class="stat">
                                <div class="statBarBase">
                                    <div class="statBar" style="height:{stats[stat]}%; background-color: {$STATS[stat].color}; box-shadow: 0 0 0.5vh {$STATS[stat].color};"></div>
                                </div>
                                <i class="fa-light fa-{$STATS[stat].icon} barIcon"></i>
                            </div>
                        {/if}
                    {/each}
                </div>
            </div>
        </div>
    </div>
    {#if (onPhone)}
        <i class="fa-regular fa-phone talkingIcon"></i>
    {:else if (onRadio)}
        <i class="fa-regular fa-walkie-talkie talkingIcon"></i>
    {/if}
    <div class="rightDiv" transition:fade={{ duration: 100 }}>
        <div class="audioBarsWrapper">
            {#each Array(7) as _, index (index)}
                <div class="audioBar {talkingOnRadio?'audioRadio': talking && 'audioTalking'}" style="{audioRange == 1?'max-height: 50%':audioRange==2&&'max-height: 70%'}"></div>
            {/each}
        </div>
        <div class="audioRangWrapper">
            {#each Array(3) as _, index (index)}
                <div class="{audioRange<index+1?'audioRangeBar':'audioBarActive'}"></div>
            {/each}
        </div>
    </div>
{/if}

<style>
    .talkingIcon {
        position: absolute;
        bottom: 12vh;
        right: 5vh;
        font-size:  3vh;
        color: yellowgreen;
        text-shadow: 0 0 2px yellowgreen;
    }
    .audioRangeBar {
        border: 1px solid rgba(165, 165, 165, 0.582);
        background-color: rgba(39, 39, 39, 0.664);
        box-shadow: 0 0 2px rgba(39, 39, 39, 0.664);
        border-radius: 0.1vh;
    }
    .audioBarActive {
        background-color: yellowgreen;
        box-shadow: 0 0 2px yellowgreen;
        border-radius: 0.1vh;
    }
    .audioRangWrapper {
        position: absolute;
        bottom: 2vh;
        right: 5vh;
        width: 5vh;
        height: 0.5vh;
        display: grid;
        grid-template-columns: repeat(3, auto);
        gap: 0.5vh;
    }
    .audioBar {
        display: block;
        position: relative;
        height: 20%;
        width: 5px;
        border-radius: 0.1vh;
        background-color: rgba(39, 39, 39, 0.664);
        box-shadow: 0 0 2px rgba(39, 39, 39, 0.664);
    }
    .audioTalking {
        background-color: yellowgreen;
        box-shadow: 0 0 2px yellowgreen;
        animation: audioPlaying 1s linear infinite;
    }
    .audioRadio {
        background-color: #2489db;
        box-shadow: 0 0 2px #2489db;
        animation: audioPlaying 1s linear infinite;
    }
    .audioBarsWrapper {
        position: absolute;
        bottom: 3.5vh;
        right: 5vh;
        width: 52px;
        height: 50px;
        display: flex;
        gap: 4px;
        align-items: center;
    }
    .barIcon {
        position: absolute;
        font-size: 2vh;
        right: 0vh;
        width: 3.2vh;
        top: 0.5vh;
        text-align: center;
    }
    .statBar {
        position: absolute;
        bottom: 0vh;
        width: 100%;
        height: 50%;
        background-color: rgb(139, 91, 252);
        box-shadow: 0 0 0.5vh rgb(139, 91, 252);
    }
    .statBarBase {
        position: absolute;
        width: 0.4vh;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.6);
    }
    .stat {
        position: relative;
        height: 3vh;
    }
    .statWrapper {
        position: absolute;
        top: 50%;
        left: 29vh;
        width: 17vh;
        height: auto;
        transform: translateY(-50%);
        display: grid;
        grid-template-columns: repeat(4, auto);
        gap: 0.5vh;
    }
    .barWrapper {
        position: relative;
    }
    .icon {
        color: rgba(255, 255, 255, 0.815);
    }
    .barTxt {
        position: absolute;
        top: 0vh;
        left: 2vh;
        color: #92db24;
        text-shadow: 1px 1px black;
    }
    .barBase {
        position: absolute;
        top: 0.8vh;
        right: 0vh;
        width: 23vh;
        height: 0.75vh;
        background-color: rgba(0, 0, 0, 0.6);
        border-radius: 0.2vh;
    }
    .healthbar {
        position: relative;
        height: 100%;
        background-color: #92db24;
        box-shadow: 0 0 0.5vh #92db24;
        transition: 200ms;
    }
    .armorBar {
        position: relative;
        height: 100%;
        overflow: hidden;
        transition: 200ms;
    }
    .armorBarWrapper {
        position: absolute;
        top: 0.9vh;
        right: 0vh;
        width: 23vh;
        height: 0.5vh;
    }
    .armorBarBase {
        position: absolute;
        height: 100%;
        width: 23vh;
        display: grid;
        grid-template-columns: repeat(5, auto);
        gap: 0.5vh;
    }
    .armorBarPill {
        border-radius: 0.5vh;
        background-color: rgba(0, 0, 0, 0.6);
    }
    .wasteWrapper {
        position: absolute;
        top: 0vh;
        left: 0vh;
        width: 100%;
        height: auto;
    }
    .barsWrapper {
        position: absolute;
        bottom: 4vh;
        left: 5vh;
        width: 28vh;
        height: auto;
    }
    .leftDiv {
        position: absolute;
        top: 5vh;
        left: 0vh;
        width: 50%;
        height: 90%;
        transform: perspective(450px) rotateY(2.5deg);
    }
    .rightDiv {
        position: absolute;
        top: 5vh;
        right: 0vh;
        width: 50%;
        height: 90%;
        transform: perspective(450px) rotateY(-2.5deg);
    }
    @keyframes audioPlaying {
        0%{
            height: 20%;
        }
        50%{
            height: 100%;
        }
        100%{
            height: 20%;
        }
    }
    .audioBar:nth-child(2){
        animation-delay: 0.6s;
    }
    .audioBar:nth-child(3){
        animation-delay: 0.4s;
    }
    .audioBar:nth-child(4){
        animation-delay: 0.5s;
    }
    .audioBar:nth-child(5){
        animation-delay: 0.8s;
    }
    .audioBar:nth-child(6){
        animation-delay: 0.3s;
    }

</style>