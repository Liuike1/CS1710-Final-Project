import matplotlib.pyplot as plt
import matplotlib.patches as patches
import re
import os


# put permutation here
GAP_PERMUTATION = "( 1,36,52,34, 9)( 2,40,35,38,53)( 3,10,28,45,54,30,12,27,43,39,18,25,16,21, 7,37)\
                         ( 4,51,33,17)( 6,47,15,31,11,13, 8,22,24,42)(20,26,44,29,49)" 
                        

# put solution here
GAP_SOLUTION = "x1*x3^-1*x6*x5^-1*x1^-1*x4*x1^-1*x3*x4*x5^-1*x4^-1*x6*x1^-1*x6^-1*x4*x5*x2*x5^-1*x4^-1*x2^-2*x6^2*x2*x1^2*x5\
                ^2*x4*x6*x2*x6^-1*x4^-1*x3^-1*x4*x5^-1*x4^-1*x1*x3^-1*x6*x2^-1*(x6^-1*x1)^2*x6*x3*x2^-1*x6*x2*x5*x4^-1*x3*x4*x3^-1*x5^\
                -1*x4^-1*x5*x4*x5*x3^-1*x5^-1*x3^-1*x1^-1*x5*x1*x6*x3^-1*x6^-1*x3*x1*x6*x3^2*x6^-1*x3^-1*x5*x1*x4*x1*x4^-1*(x5^-1*x3^-\
                1)^2*x5*x3*x1*x5*x1*x5^-1*x3^-1*x1^-1*x3*(x1*x3^-1)^2*x6*x3*x6^-1*x1^2*x3*x1^-1*x3*x1*x3^-1*x4^-1*x3*x4*x1^-1*x3^-1*x1\
                ^2*x3^-1*x1*x3*x1*x5*x1^-1*x5^-2*x1^-1*x3^-1*x1*x3*x5*x1^3*x3^-1*x1^-1*x6*x3^-1*x6^-1*x3*x1*x3*x1^-2*x3*x5*x1*x5^-1*x1\
                ^-1*x3^-1*x1^2*x3^-1*x4^-1*x3^-1*x4*x3^-2*x1^-1*x3*x1*x5*x1^-1*x5^-1*x3^-1*x1^-3*x3*x1*x3^-1*x4^-1*x3^-1*x4*x3^2*x1^-1\
                *x3^-1*x1*x3*x1*x5*x1^-1*x5^-1*x3^-1*x1*x5^-1*x3^-1*(x1^-1*x3*x1*x5)^2*x1^-1*x5^-1*x1*x5*x1^-1*(x5^-1*x3^-1)^2*x1^-1*x\
                3*x1*x5*x1*x3*x1*x5*x1^-1*x5^-1*x3^-1*x1^-1*x3^-1*x1^2*x3*x1*x3^-1*x1*x6*x3^-1*x6^-1*x3*x1*x3*x1^-2*x5*x1^-1*x5^-1*x3*\
                x5*x1*x5^-1*x1^-1*x3^-1*x1^-1*x3*(x5*x1*x5^-1*x1^-1)^2*x3^-1*x1^2*x3^-1*x4^-1*x3^-1*x4*x3^-2*x1^-2*x3*x1*x5*x1^-1*x5^-\
                1*x3^-1*x1*x3^-1*x4^-1*x3^-1*x4*x3^-2*x1^-1*x3*x1*x3^-2*x4^-1*x3^-1*x4*x3^-1*x1^-1*x3^-1*x1*x3^-1*x4^-1*x3^-1*x4*x3^-2\
                *x1^-1"


# ==========================================
# 1. CONFIGURATION: 3x3 MAPPING (1-54)
# ==========================================

STICKER_COLORS = {}
for i in range(1, 10): STICKER_COLORS[i] = '#0051BA'   # Front (Blue)
for i in range(10, 19): STICKER_COLORS[i] = '#C41E3A'  # Right (Red)
for i in range(19, 28): STICKER_COLORS[i] = '#FF5800'  # Back (Orange)
for i in range(28, 37): STICKER_COLORS[i] = '#009E60'  # Left (Green)
for i in range(37, 46): STICKER_COLORS[i] = '#FFFFFF'  # Up (White)
for i in range(46, 55): STICKER_COLORS[i] = '#FFD500'  # Down (Yellow)

COORDS = {
    37: (3,8), 38: (4,8), 39: (5,8), 40: (3,7), 41: (4,7), 42: (5,7), 43: (3,6), 44: (4,6), 45: (5,6), # Up
    28: (0,5), 29: (1,5), 30: (2,5), 31: (0,4), 32: (1,4), 33: (2,4), 34: (0,3), 35: (1,3), 36: (2,3), # Left
    1: (3,5),  2: (4,5),  3: (5,5),  4: (3,4),  5: (4,4),  6: (5,4),  7: (3,3),  8: (4,3),  9: (5,3),  # Front
    10: (6,5), 11: (7,5), 12: (8,5), 13: (6,4), 14: (7,4), 15: (8,4), 16: (6,3), 17: (7,3), 18: (8,3), # Right
    19: (9,5), 20: (10,5), 21: (11,5), 22: (9,4), 23: (10,4), 24: (11,4), 25: (9,3), 26: (10,3), 27: (11,3), # Back
    46: (3,2), 47: (4,2), 48: (5,2), 49: (3,1), 50: (4,1), 51: (5,1), 52: (3,0), 53: (4,0), 54: (5,0)  # Down
}

# ==========================================
# 2. PARSING LOGIC
# ==========================================

def parse_gap_permutation(perm_str):
    if perm_str.strip() == "()": return []
    cycles_raw = re.findall(r'\(([^)]+)\)', perm_str)
    cycles = []
    for cycle in cycles_raw:
        cycles.append([int(n.strip()) for n in cycle.split(',')])
    return cycles

# Use the exact strings from your GAP script to guarantee identical math
GAP_MOVES = {
    'U': "(37,39,45,43)(38,42,44,40)(21,12,3,30)(20,11,2,29)(19,10,1,28)",
    'D': "(46,48,54,52)(47,51,53,49)(34,7,16,25)(35,8,17,26)(36,9,18,27)",
    'L': "(28,30,36,34)(29,33,35,31)(37,1,46,27)(40,4,49,24)(43,7,52,21)",
    'R': "(10,12,18,16)(11,15,17,13)(45,19,54,9)(42,22,51,6)(39,25,52,3)",
    'F': "(1,3,9,7)(2,6,8,4)(43,10,48,36)(44,13,47,33)(45,16,46,30)",
    'B': "(19,21,27,25)(20,24,26,22)(18,39,28,54)(15,38,31,53)(12,37,34,52)"
}

# Convert the GAP strings into Python arrays automatically
MOVES = {face: parse_gap_permutation(cycles) for face, cycles in GAP_MOVES.items()}

def apply_cycles(state_array, cycles, reverse=False):
    new_state = state_array.copy()
    for cycle in cycles:
        if len(cycle) < 2: continue
        current_cycle = cycle[::-1] if reverse else cycle
        temp = new_state[current_cycle[-1] - 1]
        for i in range(len(current_cycle) - 1, 0, -1):
            new_state[current_cycle[i] - 1] = new_state[current_cycle[i-1] - 1]
        new_state[current_cycle[0] - 1] = temp
    return new_state

def parse_single_move(move_str):
    # Mapping explicitly updated to match your Group(u,d,l,r,f,b) order
    mapping = {'x1': 'U', 'x2': 'D', 'x3': 'L', 'x4': 'R', 'x5': 'F', 'x6': 'B'}
    move_str = move_str.strip()
    base = move_str[:2]
    face = mapping.get(base, base)
    
    is_inverse, times = False, 1
    readable = face
    
    if '^-1' in move_str or '^3' in move_str:
        is_inverse = True
        readable = f"{face}'"
    elif '^-2' in move_str or '^2' in move_str:
        times = 2
        readable = f"{face}2"
    elif '^-3' in move_str:
        times = 1
        readable = face
        
    return face, readable, is_inverse, times

def expand_gap_solution(sol_str):
    def replacer(match):
        inner_moves = match.group(1)
        power = int(match.group(2))
        return "*".join([inner_moves] * power)
    return re.sub(r'\(([^)]+)\)\^(\d+)', replacer, sol_str)

# ==========================================
# 3. VISUALIZATION
# ==========================================

def draw_cube(state_array, title="3x3 Rubik's Cube State", filename=None):
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 9)
    ax.set_aspect('equal')
    ax.axis('off')
    
    for current_position in range(1, 55):
        sticker_value = state_array[current_position - 1]
        color = STICKER_COLORS[sticker_value]
        x, y = COORDS[current_position]
        
        rect = patches.Rectangle((x, y), 1, 1, linewidth=2, edgecolor='black', facecolor=color)
        ax.add_patch(rect)
        
        text_color = 'black' if color in ['#FFFFFF', '#FFD500'] else 'white'
        ax.text(x + 0.5, y + 0.5, str(sticker_value), 
                color=text_color, fontsize=10, weight='bold',
                ha='center', va='center')

    plt.title(title, fontsize=18, pad=20)
    
    if filename:
        plt.savefig(filename, bbox_inches='tight')
        plt.close(fig)
    else:
        plt.show()

# ==========================================
# 4. MAIN EXECUTION
# ==========================================
if __name__ == "__main__":
    
    gap_permutation = GAP_PERMUTATION
    gap_solution = GAP_SOLUTION
    
    output_dir = "solution_steps_3x3"
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    initial_state = list(range(1, 55))
    scramble_cycles = parse_gap_permutation(gap_permutation)
    current_state = apply_cycles(initial_state, scramble_cycles)
    
    print("Saving Step 0: Scrambled State")
    draw_cube(current_state, title="Step 0: Scrambled", filename=f"{output_dir}/step_00_scrambled.png")
    
    if gap_solution.strip():
        clean_solution = re.sub(r'[\s\\]', '', gap_solution)
        flat_solution = expand_gap_solution(clean_solution)
        moves = flat_solution.split('*')
        
        for i, move in enumerate(moves):
            face, readable_name, is_inverse, times = parse_single_move(move)
            
            for _ in range(times):
                current_state = apply_cycles(current_state, MOVES[face], reverse=is_inverse)
            
            safe_name = readable_name.replace("'", "_prime")
            filename = f"{output_dir}/step_{i+1:03d}_{safe_name}.png"
            
            print(f"Saving Step {i+1}: {readable_name}")
            draw_cube(current_state, title=f"Step {i+1}: applied {readable_name}", filename=filename)
            
    print(f"\nSuccess! All 3x3 transition images saved to '{output_dir}'.")