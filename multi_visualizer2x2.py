import matplotlib.pyplot as plt
import matplotlib.patches as patches
import re
import os

# ==========================================
# 1. CONFIGURATION & RE-MAPPED DICTIONARIES
# ==========================================

# STICKER_COLORS = {
#     1: '#0051BA', 2: '#0051BA', 3: '#0051BA', 4: '#0051BA',
#     5: '#C41E3A', 6: '#C41E3A', 7: '#C41E3A', 8: '#C41E3A',
#     9: '#009E60', 10: '#009E60', 11: '#009E60', 12: '#009E60',
#     13: '#FFD500', 14: '#FFD500', 15: '#FFD500', 16: '#FFD500',
#     17: '#FF5800', 18: '#FF5800', 19: '#FF5800', 20: '#FF5800',
#     21: '#FFFFFF', 22: '#FFFFFF', 23: '#FFFFFF', 24: '#FFFFFF',
# }

STICKER_COLORS = {
    17: '#0051BA', 18: '#0051BA', 19: '#0051BA', 20: '#0051BA',
    5: '#C41E3A', 6: '#C41E3A', 7: '#C41E3A', 8: '#C41E3A',
    1: '#009E60', 2: '#009E60', 3: '#009E60', 4: '#009E60',
    13: '#FFD500', 14: '#FFD500', 15: '#FFD500', 16: '#FFD500',
    9: '#FF5800', 10: '#FF5800', 11: '#FF5800', 12: '#FF5800',
    21: '#FFFFFF', 22: '#FFFFFF', 23: '#FFFFFF', 24: '#FFFFFF',
}

COORDS = {
    21: (2, 5), 22: (3, 5), 23: (2, 4), 24: (3, 4),
    9: (0, 3), 10: (1, 3), 11: (0, 2), 12: (1, 2),
    1: (2, 3), 2: (3, 3), 3: (2, 2), 4: (3, 2),
    5: (4, 3), 6: (5, 3), 7: (4, 2), 8: (5, 2),
    17: (6, 3), 18: (7, 3), 19: (6, 2), 20: (7, 2),
    13: (2, 1), 14: (3, 1), 15: (2, 0), 16: (3, 0)
}

# Copying the exact cycles from your GAP .g file definitions
MOVES = {
    'U': [[21,22,24,23], [6,2,10,19], [5,1,9,20]],
    'R': [[7,5,6,8], [4,24,20,16], [2,22,18,14]],
    'F': [[1,2,4,3], [5,14,12,23], [7,13,10,24]]
}

# ==========================================
# 2. PARSING LOGIC
# ==========================================

def parse_gap_permutation(perm_str):
    if perm_str.strip() == "()":
        return []
    cycles_raw = re.findall(r'\(([^)]+)\)', perm_str)
    cycles = []
    for cycle in cycles_raw:
        num_list = [int(n.strip()) for n in cycle.split(',')]
        cycles.append(num_list)
    return cycles

def apply_cycles(state_array, cycles, reverse=False):
    """Applies disjoint cycles to the current state array. 
       If reverse=True, it executes the inverse move."""
    new_state = state_array.copy()
    
    for cycle in cycles:
        if len(cycle) < 2:
            continue
            
        # Reverse the cycle array if we need the inverse move (e.g., U')
        current_cycle = cycle[::-1] if reverse else cycle
        
        temp = new_state[current_cycle[-1] - 1]
        for i in range(len(current_cycle) - 1, 0, -1):
            new_state[current_cycle[i] - 1] = new_state[current_cycle[i-1] - 1]
        new_state[current_cycle[0] - 1] = temp
        
    return new_state

# def parse_single_move(move_str):
#     """Parses a single GAP generator into base face, readable name, reverse flag, and execution count."""
#     mapping = {'x1': 'U', 'x2': 'R', 'x3': 'F'}
#     move_str = move_str.strip()
#     base = move_str[:2]
#     face = mapping.get(base, base)
    
#     is_inverse = False
#     times = 1
#     readable = face
    
#     if '^-1' in move_str:
#         is_inverse = True
#         readable = f"{face}'"
#     elif '^-2' in move_str or '^2' in move_str:
#         times = 2
#         readable = f"{face}2"
        
#     return face, readable, is_inverse, times

def parse_single_move(move_str):
    """Parses a single GAP generator into base face, readable name, reverse flag, and execution count."""
    mapping = {'x1': 'U', 'x2': 'R', 'x3': 'F'}
    move_str = move_str.strip()
    base = move_str[:2]
    face = mapping.get(base, base)
    
    is_inverse = False
    times = 1
    readable = face
    
    # Handle inverses and ^3 (3 clockwise turns = 1 counter-clockwise turn)
    if '^-1' in move_str or '^3' in move_str:
        is_inverse = True
        readable = f"{face}'"
    # Handle double turns
    elif '^-2' in move_str or '^2' in move_str:
        times = 2
        readable = f"{face}2"
    # Handle ^-3 (3 counter-clockwise turns = 1 normal clockwise turn)
    elif '^-3' in move_str:
        times = 1
        readable = face
        
    return face, readable, is_inverse, times

# ==========================================
# 3. VISUALIZATION
# ==========================================

def draw_cube(state_array, title="2x2 Rubik's Cube State", filename=None):
    """Draws the unfolded cube net. If filename is provided, saves it; otherwise shows it."""
    fig, ax = plt.subplots(figsize=(8, 8))
    
    ax.set_xlim(0, 8)
    ax.set_ylim(0, 6)
    ax.set_aspect('equal')
    ax.axis('off')
    
    for current_position in range(1, 25):
        sticker_value = state_array[current_position - 1]
        color = STICKER_COLORS[sticker_value]
        x, y = COORDS[current_position]
        
        rect = patches.Rectangle((x, y), 1, 1, linewidth=2, edgecolor='black', facecolor=color)
        ax.add_patch(rect)
        
        text_color = 'black' if color in ['#FFFFFF', '#FFD500'] else 'white'
        ax.text(x + 0.5, y + 0.5, str(sticker_value), 
                color=text_color, fontsize=14, weight='bold',
                ha='center', va='center')

    plt.title(title, fontsize=16, pad=20)
    
    if filename:
        plt.savefig(filename, bbox_inches='tight')
        plt.close(fig) # Close to prevent memory overload from too many open windows
    else:
        plt.show()

# ==========================================
# 4. MAIN EXECUTION
# ==========================================
if __name__ == "__main__":
    gap_permutation = "( 1,16, 2)( 3,13,12)( 4, 6,21,14,20,19, 7,22, 9)( 5,23,18)( 8,24,10)"
    gap_solution = "x3^-1*x2*x1*x2*x3^-2*x1^-1*x3^2*x2^-1*x3^-1*x1^-1*x2^-1*x1*x2*x3*x1*x2^-1*x1^-1*x2^-1*x3^-1*x1^3*x2^2*x3*x2*\
                    x3^-1*x2*x1^-1*x3*x2^-1*x3^-1"

    
    # Create a directory for the output images
    output_dir = "solution_steps"
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # 1. Setup Initial Scramble
    initial_state = list(range(1, 25))
    scramble_cycles = parse_gap_permutation(gap_permutation)
    current_state = apply_cycles(initial_state, scramble_cycles)
    
    # Save Step 0
    print("Saving Step 0: Scrambled State")
    draw_cube(current_state, title="Step 0: Scrambled", filename=f"{output_dir}/step_00_scrambled.png")
    
    # 2. Iterate through the solution moves
    if gap_solution.strip():
        moves = gap_solution.split('*')
        
        for i, move in enumerate(moves):
            face, readable_name, is_inverse, times = parse_single_move(move)
            
            # Apply the specific move cycle to the array
            for _ in range(times):
                current_state = apply_cycles(current_state, MOVES[face], reverse=is_inverse)
            
            # Save the image for this step
            safe_name = readable_name.replace("'", "_prime")
            filename = f"{output_dir}/step_{i+1:02d}_{safe_name}.png"
            
            print(f"Saving Step {i+1}: {readable_name}")
            draw_cube(current_state, title=f"Step {i+1}: applied {readable_name}", filename=filename)
            
    print(f"\nSuccess! All transition images have been saved to the '{output_dir}' folder in your current directory.")