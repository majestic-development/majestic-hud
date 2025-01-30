<script lang="ts">
    import { CONFIG, IS_BROWSER } from './stores/stores';
    import { InitialiseListen } from '@utils/listeners';
    import { ReceiveEvent, SendEvent } from '@utils/eventsHandlers';
    import Status from '@components/status.svelte';
    import VehicleHud from '@components/vehicleHud.svelte';
    CONFIG.set({
        fallbackResourceName: 'debug',
        allowEscapeKey: true,
    });
    InitialiseListen();
</script>

<main>
    <Status/>
    <VehicleHud/>
</main>

<style>
   main {
        position: absolute;
        left: 0;
        top: 0;
        z-index: 100;
        user-select: none;
        box-sizing: border-box;
        padding: 0;
        margin: 0;
        height: 100%;
        width: 100%;
    }
</style>

{#if import.meta.env.DEV}
    {#if $IS_BROWSER}
        {#await import('./providers/Debug.svelte') then { default: Debug }}
            <Debug />
        {/await}
    {/if}
{/if}
