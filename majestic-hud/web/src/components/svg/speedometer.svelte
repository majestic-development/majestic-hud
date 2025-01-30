<script lang="ts">
	import { linear } from 'svelte/easing';
	import { tweened } from 'svelte/motion';

	export let displayOutline: boolean = true;
	export let height: number = 50;
	export let innerColor: string = "#212121";
	export let innerColorOpacity: number = 1;
	export let outlineColor: string = "red";
	export let outlineColorOpacity: number = 0.4;
	export let progressColor: string = "red";
	export let progressValue: number = 100;
	export let ringSize: number = 4;
	export let rotateDegree: number = 0;
	export let translateX: number = 0;
	export let translateY: number = 0;
	export let width: number = 50;
	export let maxLengthDisplay: number = 100;
	export let maxProgressValue: number = 100;
	export let showInnerBG: boolean = false;
	export let displayNumber: number = 0;
	export let text: string = "";
	
	let radius: number = 25;
	let transposeValue: number = progressValue / maxProgressValue * 100;
  
	const progressTween = tweened(transposeValue, {
		  duration: 200,
		  easing: linear,
	  });
  
	const displayNumberTween = tweened(displayNumber, {
	  duration: 600,
	  easing: linear,
	})
  
	$: {
	  progressValue = Math.min(progressValue, maxProgressValue);
	  transposeValue = progressValue / maxProgressValue * 100;
	  progressTween.set(transposeValue);
	}
  
	$: displayNumberTween.set(displayNumber);
  
	let normalizedRadius: number = radius - (ringSize/2);
	let circumference: number = normalizedRadius * 2 * Math.PI;
	let strokeDashoffset: number = circumference - $progressTween / 100 * circumference;
  
	$: radius = height > width ? height/2 : width/2;
	$: {
	  normalizedRadius = radius - (ringSize/2);
	  circumference = (normalizedRadius * 2 * Math.PI);
	}
	$: {
	  strokeDashoffset = (circumference) - ($progressTween/(100/maxLengthDisplay)) / 100 * circumference;
	}
  </script>
  
  <svg
	width="100%"
	height="100%"
	viewBox = "0 0 {radius * 2} {radius * 2}"
	overflow="visible"
  >
	<g 
	  transform="
	  { rotateDegree > 0 ? "rotate("+rotateDegree+" "+radius+" "+radius+")": ""}
	  { "translate("+translateX+" "+translateY+")" }"
	>
	  {#if displayOutline}
		<circle
		  opacity={outlineColorOpacity}
		  fill="transparent"
		  stroke={outlineColor}
		  stroke-dashoffset={circumference - maxLengthDisplay / 100 * circumference}
		  stroke-dasharray={circumference + ' ' + circumference}
		  stroke-width={ringSize}
		  r={normalizedRadius}
		  cx={radius}
		  cy={radius}
		  transform="rotate(-90, {radius}, {radius})"
		/>
	  {/if}
	  {#if showInnerBG}
	  <circle
		fill={innerColor}
		fill-opacity={innerColorOpacity}
		stroke="transparent"
		stroke-dashoffset={0}
		stroke-dasharray={circumference +' ' + circumference}
		stroke-width={ringSize-0.6}
		r={normalizedRadius - (ringSize/2) + 0.1}
		cx={radius}
		cy={radius}
		transform="rotate(-90, {radius}, {radius})"
	  />
	  {/if}
	  <circle
		stroke="{progressColor}"
		fill="transparent"
		stroke-dashoffset={strokeDashoffset}
		stroke-dasharray={circumference + ' ' + circumference}
		stroke-width={ringSize}
		r={normalizedRadius}
		cx={radius}
		cy={radius}
		transform="rotate(-90, {radius}, {radius})"
		style="filter: drop-shadow(0 0 0.1vh {progressColor});"
	  />
	</g>
	{#if text}
	<text class="vehicle-number" x="50%" y="45%" dominant-baseline="middle" text-anchor="middle">
	  {Math.floor($displayNumberTween)}
	</text>
	<text class="vehicle-text" x="50%" y="70%" dominant-baseline="middle" text-anchor="middle">
	  {text}
	</text>
	{/if}
  </svg>
  
  <style>
	.vehicle-number {
		font-family: 'Akshar';
	  	font-size: 2vh;
	  	fill: rgba(255, 255, 255, 0.9);
	}
  
	.vehicle-text {
		font-family: 'Akshar';
		font-size: 0.95vh;
		fill: rgba(255, 255, 255, 0.75);
	}
  
</style>