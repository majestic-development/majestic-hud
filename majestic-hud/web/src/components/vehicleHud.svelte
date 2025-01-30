<script lang="ts">
	import { scale } from 'svelte/transition';
	import { quintOut } from 'svelte/easing';
	import Speedometer from './svg/speedometer.svelte';
	import { ReceiveEvent } from '@utils/eventsHandlers';
	import Compass from './compass.svelte';
	let visible:boolean = false;
	let rpm: number = 0;
	let speed:number = 0;
	let fuel:number = 50;
	let engineOn:boolean = false;
	let beltOn:boolean = false;
	ReceiveEvent('updateVehicle', (data: {showing: boolean, rpm: number, speed: number, fuel:number, engineOn:boolean, beltOn:boolean}): void => {
		visible = data.showing;
		rpm = data.rpm;
		speed = data.speed;
		fuel = data.fuel;
		engineOn = data.engineOn;
		beltOn = data.beltOn;
    });
</script>

{#if (visible)}
	<Compass/>
	<div class="speedometer" transition:scale={{ duration: 200, opacity: 0.0, start: 0.0, easing: quintOut }}>
		<Speedometer maxLengthDisplay={72} rotateDegree={230} ringSize={3.5} progressColor={rpm < 0.9? 'greenyellow' : '#FF3838'} outlineColor={'black'} outlineColorOpacity={0.6} height={60} width={60} progressValue={rpm} text={"MPH"} displayNumber={speed} maxProgressValue={1}/>
		<div class="statsWrapper">
			<div class="statWrapper">
				FUEL
				<div class="statBarBase">
					<div class="statBar" style="width:{fuel}%; background-color: rgb(255, 185, 34);"></div>
				</div>
			</div>
			<div class="statWrapper">
				ENG
				<div class="statBarBase">
					<div class="statBar" style="width:{engineOn? 100: 0}%;"></div>
				</div>
			</div>
			<div class="statWrapper">
				BELT
				<div class="statBarBase">
					<div class="statBar" style="width:{beltOn? 100: 0}%;"></div>
				</div>
			</div>
		</div>
	</div>
{/if}


<style>
	.statBar {
		position: absolute;
		width: 100%;
		height: 100%;
		background-color: yellowgreen;
		transition: 200ms;
	}
	.statBarBase {
		position: absolute;
		bottom: 0vh;
		width: 100%;
		height: 0.7vh;
		border: 1px solid rgba(165, 165, 165, 0.582);
        background-color: rgba(39, 39, 39, 0.664);
        box-shadow: 0 0 2px rgba(39, 39, 39, 0.664);
        border-radius: 50px;
		overflow: hidden;
	}
	.statWrapper {
		position: relative;
		text-align: center;
		font-family: 'Akshar';
		color: rgba(255, 255, 255, 0.85);
		font-size: 1.75vh;
		text-shadow: 0 0 2px black;
	}
	.statsWrapper {
		position: absolute;
		right: 3vh;
		bottom: 0vh;
		width: 14vh;
		height: 3vh;
		display: grid;
		grid-template-columns: repeat(3, auto);
        gap: 0.5vh;
	}
	.speedometer {
		position: absolute;
		right: 12vh;
		bottom: 5vh;
		width: 20vh;
		height: 20vh;
	}
</style>