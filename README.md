# Race Game

A simple endless runner-style game built with Godot Engine. Guide your character through obstacles, survive as long as possible, and challenge yourself across two levels.

## Features
- Simple obstacle generation (stumps, barrels, rocks, birds)
- Smooth speed and difficulty progression
- Two levels with increasing challenge
  - **Level 1:** Has a finish score and transitions when completed
  - **Level 2:** Endless run with higher speed and more obstacles
- Score tracking and remaining distance indicator
- AI Coach that gives short motivational or instructional words

## How to Play
1. Download the exported version for your operating system:  
   👉 [Exported Builds (macOS & Windows)](https://drive.google.com/drive/folders/1_1KEycaVRVUSBJLqb4-NY8uKEpXVBFPY?usp=share_link)  
2. Run the game (`BunnyEscapeGame.app` on macOS, `.exe` on Windows).  
3. Press **Enter** to start the level.  
4. Control the player to run and avoid obstacles.  
5. Reach the finish score to complete **Level 1** and unlock **Level 2**.  
6. In **Level 2**, survive as long as you can — there is no finish line.  
7. Watch your **Score** and **Remaining** distance on the HUD.  
8. Listen to the **AI Coach** for short feedback and encouragement.

## Setup (For Developers)
- Requires **Godot 4.x**.  
- Clone this repository and open it in Godot to view or modify.  
- Preview by running `level1.tscn` (Level 1) or `level2.tscn` (Level 2).

## Project Report
You can read the full documentation of the project here:  
📄 [Race Game Project Report (PDF)](./raceGame-group3Report.pdf)

## Exported Builds
The game has been exported for both **macOS** and **Windows**.  
👉 [Download Builds](https://drive.google.com/drive/folders/1_1KEycaVRVUSBJLqb4-NY8uKEpXVBFPY?usp=share_link)

## Demo Video
A short gameplay demo with explanation is available here:  
🎥 [Race Game Demo Video](https://drive.google.com/file/d/13VbvZZNTxFMndvY5FStuAtaQnGUQe9UO/view?usp=share_link)

## Structure
- `scenes/level1/` – First level scenes and assets  
- `scenes/level2/` – Second level with increased difficulty  
- `scripts/` – GDScript logic for game flow and player movement  
- `assets/` – Visual and audio resources  
- `raceGame-group3Report.pdf` – Full project report  

---

Happy racing! 🚀🐇
