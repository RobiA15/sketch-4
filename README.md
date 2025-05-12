# Water Wave Simulation with Energy Dashboard

An interactive water wave simulation built with Processing that combines realistic physics with comprehensive energy visualization. This project demonstrates soft-body physics using Verlet integration, real-time energy calculations, and dynamic bubble effects.


## Features

### Interactive Water Simulation
- **Realistic Wave Physics**: Uses Verlet integration for stable, physically accurate water movement
- **Soft-body Dynamics**: Each water surface consists of interconnected nodes with spring forces
- **Damping System**: Natural wave decay for realistic water behavior
- **Interactive Wave Generation**: Add energy to the system by pressing spacebar

### Energy Dashboard
- **Real-time Energy Tracking**: Monitor kinetic and potential energy separately
- **Energy History Graph**: 5-second historical view of energy changes
- **Energy Distribution**: Pie chart showing kinetic vs potential energy ratios
- **System Parameters**: View current physics constants and settings

### Bubble System
- **Dynamic Bubble Generation**: Bubbles spawn randomly from surface nodes
- **Realistic Bubble Behavior**: Each bubble has unique size, speed, and movement patterns
- **Natural Motion**: Includes vertical rise with slight horizontal wobble for realism
- **Surface Interaction**: Bubbles pop when they reach the water surface

## Requirements

- Processing 3.0 or newer
- No additional libraries required - uses only built-in Processing functions

## Installation and Usage

1. **Download Processing** from [https://processing.org/download/](https://processing.org/download/)

2. **Clone or download this repository**

3. **Open the project**
   - Launch Processing IDE
   - Open `main.pde` from the project folder
   - Processing will automatically load all related .pde files

4. **Run the simulation**
   - Click the Play button (triangle) in Processing IDE
   - Or press Ctrl+R (Cmd+R on Mac)

## Controls
- **SPACEBAR**: Add waves to the water system
- **D**: Toggle between water simulation view and energy dashboard
- **ESC**: Exit the program

## Technical Details

### Physics Engine

The simulation uses Verlet integration, a numerical method particularly well-suited for particle systems because it:
- Maintains energy conservation better than Euler integration
- Provides more stable results for spring-based systems
- Handles constraints naturally

#### Key Physics Components:

1. **Spring Forces**
   ```
   F_spring = -k × displacement
   ```
   Where `k` is the spring constant (springing parameter)

2. **Tension Forces**
   ```
   F_tension = k_tension × (neighbor_height - current_height)
   ```
   Creates connections between adjacent nodes

3. **Verlet Integration Formula**
   ```
   new_position = 2 × current_position - previous_position + acceleration × dt²
   ```

### Energy Calculations

The system tracks two types of energy:

1. **Kinetic Energy**: `E_k = ½mv²`
   - Based on the velocity of each water node
   - Higher when waves are moving quickly

2. **Potential Energy**: `E_p = ½kx²`
   - Based on displacement from rest position
   - Higher when water surface is deformed

Total energy is conserved in the system (minus damping losses), creating realistic wave behavior.

### Code Architecture

The project is organized into six main components:

#### `main.pde`
- Central coordination and setup
- Handles user input and screen switching
- Main draw loop and initialization

#### `WaterPhysics.pde`
- Verlet integration implementation
- Energy calculations
- Wave generation algorithms

#### `WaterDrawing.pde`
- Visual rendering of water surface
- Uses `curveVertex()` for smooth water appearance
- Handles edge cases for screen boundaries

#### `Bubble.pde`
- Individual bubble class definition
- Properties: position, size, speed, transparency
- Movement and lifecycle management

#### `BubbleMechanics.pde`
- Bubble spawning system
- Population management
- Rendering all active bubbles

#### `Dashboard.pde`
- Energy meter visualization
- Historical energy graphs
- Pie chart for energy distribution
- System parameter display

## Customization

You can easily modify the simulation by adjusting these parameters in `main.pde`:

### Physics Parameters
```java
float springing = 0.02;    // Spring strength (lower = looser waves)
float damping = 0.99;      // Energy loss per frame (lower = more loss)
float tension = 0.020;     // Node-to-node coupling (higher = stiffer surface)
```

### Energy Settings
```java
float energyPerPress = 500;  // Energy added per spacebar press
float maxEnergy = 2000;      // Maximum system energy
```

### Bubble Parameters
```java
float bubbleSpawnChance = 0.5;  // Probability of bubble spawn (0-1)
// Bubble timers range: 120-240 frames (2-4 seconds at 60fps)
```

### Visual Settings
```java
int nodes = 80;  // Number of water surface points (more = smoother)
```

## Educational Applications

This simulation demonstrates several important concepts:

### Physics Concepts
- Wave propagation and interference
- Energy conservation and transfer
- Harmonic motion and damping
- Soft-body dynamics

### Programming Concepts
- Object-oriented design
- Real-time simulation
- Data visualization
- State management

### Mathematical Concepts
- Numerical integration methods
- Trigonometric functions
- Noise functions for natural variation
- Statistical visualization

## Performance Considerations

- The simulation runs at 60 FPS by default
- Memory usage scales with the number of nodes and bubbles
- Energy history is stored in circular buffers for efficiency
- Consider reducing `nodes` count if performance is an issue

## Contributing

Feel free to submit issues and enhancement requests! Some ideas for contributions:

- Additional wave generation patterns
- More sophisticated bubble physics
- Export functionality for energy data
- Sound integration
- Mouse-based wave interaction

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Created using Processing, an open-source programming language built for artists, designers, and beginners.

## Further Reading

- [Processing Documentation](https://processing.org/reference/)
- [Verlet Integration Explained](https://en.wikipedia.org/wiki/Verlet_integration)
- [Game Physics Tutorial](https://gafferongames.com/post/integration_basics/)
- [Springs and Soft Bodies](https://www.cs.cmu.edu/~baraff/papers/sig03.pdf)
