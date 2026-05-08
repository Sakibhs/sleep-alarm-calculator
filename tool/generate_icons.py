"""
Sleep Alarm Calculator app logo — professional alarm clock mark.

Design principles:
  * Confident, opaque shapes — no muddy translucent overlays.
  * One brand gradient (frame) + one solid background. Restrained palette.
  * Proper bell silhouettes (not blurry circles), curved hammer arc,
    tapered diamond clock hands, dot hour markers with bar accents at
    12 / 3 / 6 / 9, and properly attached angled legs with rounded feet.
  * Hands set to 10:10 (the universal "friendly clock" pose).
  * Subtle drop shadow under the body adds depth without glow halos.
"""

from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path
import math

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "icon"
OUT.mkdir(parents=True, exist_ok=True)

# --- Brand palette ---
PRIMARY_START = (108, 99, 255)   # #6C63FF
PRIMARY_END   = (59, 130, 246)   # #3B82F6
PRIMARY_DEEP  = (79, 70, 229)    # #4F46E5 (for solid clock body)
PRIMARY_LIGHT = (139, 134, 255)
BG_SOLID      = (15, 19, 36)     # #0F1324 — single solid bg, very dark navy
FACE_COLOR    = (245, 248, 255)
DIAL_DARK     = (24, 30, 56)
DIAL_DARK_SOFT= (60, 70, 110)
ACCENT_DOT    = (255, 196, 64)

SS = 4
W = 1024
BIG = W * SS


# ---------------- helpers ----------------

def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def diagonal_gradient(size, c1, c2):
    img = Image.new("RGB", (size, size), c1)
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * (size - 1))
            px[x, y] = lerp(c1, c2, t)
    return img


def rounded_mask(size, radius):
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size - 1, size - 1), radius=radius, fill=255
    )
    return mask


def gradient_fill(size, shape_alpha, c1, c2):
    grad = diagonal_gradient(size, c1, c2).convert("RGBA")
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.paste(grad, (0, 0), shape_alpha)
    return out


def mask_from_draw(size, draw_callable):
    m = Image.new("L", (size, size), 0)
    draw_callable(ImageDraw.Draw(m))
    return m


def rotate_about(point, center, angle_rad):
    px, py = point
    cx, cy = center
    s, c = math.sin(angle_rad), math.cos(angle_rad)
    dx, dy = px - cx, py - cy
    return (cx + dx * c - dy * s, cy + dx * s + dy * c)


def bell_polygon(cx, cy, w, h, tilt_rad=0.0):
    """
    Bell silhouette: a rounded dome (semi-ellipse) on top, sides that
    flare gently outward, and a flat rim at the bottom. No pointed knob —
    a clean dome reads more clearly as an alarm clock bell at small sizes.
    """
    pts = []

    # Dome top: semi-ellipse from left-shoulder around to right-shoulder.
    dome_w = w * 0.78
    dome_h = h * 0.65
    dome_cy = cy - h * 0.10
    n = 30
    for i in range(n + 1):
        a = math.pi + math.pi * i / n  # 180° → 360°
        pts.append((cx + (dome_w / 2) * math.cos(a),
                    dome_cy + dome_h / 2 * math.sin(a)))

    # Right flare down to rim (gentle outward curve)
    p0 = pts[-1]
    p2 = (cx + w * 0.50, cy + h * 0.45)
    p1 = (cx + w * 0.46, cy + h * 0.18)  # control: slight outward bulge
    for i in range(1, 9):
        t = i / 8
        x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0]
        y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]
        pts.append((x, y))

    # Bottom flat rim
    pts.append((cx + w * 0.50, cy + h * 0.50))
    pts.append((cx - w * 0.50, cy + h * 0.50))

    # Left flare back up to dome
    p0 = (cx - w * 0.50, cy + h * 0.45)
    p1 = (cx - w * 0.46, cy + h * 0.18)
    p2 = (cx - dome_w / 2, dome_cy)
    for i in range(0, 9):
        t = i / 8
        x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0]
        y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]
        pts.append((x, y))

    if tilt_rad:
        pts = [rotate_about(p, (cx, cy), tilt_rad) for p in pts]
    return pts


def diamond_hand_polygon(cx, cy, angle_deg_from_12, length, base_w, tip_w):
    """
    Tapered diamond/lozenge hand: starts at center pivot with `base_w` width,
    tapers to `tip_w` near the tip. Returns 4 points.
    """
    ang = math.radians(angle_deg_from_12 - 90)  # -90 so 0° = up
    perp = ang + math.pi / 2
    # Tail point (slightly behind pivot for a proper hand)
    tail_len = length * 0.18
    tail = (cx - tail_len * math.cos(ang), cy - tail_len * math.sin(ang))
    tip = (cx + length * math.cos(ang), cy + length * math.sin(ang))
    # Middle/widest point a bit past pivot toward tip
    mid_t = 0.30
    mid = (cx + (length * mid_t) * math.cos(ang),
           cy + (length * mid_t) * math.sin(ang))
    half = base_w / 2
    side_a = (mid[0] + half * math.cos(perp), mid[1] + half * math.sin(perp))
    side_b = (mid[0] - half * math.cos(perp), mid[1] - half * math.sin(perp))
    return [tail, side_a, tip, side_b]


# ---------------- main composition ----------------

def build_foreground(s, with_background=True):
    canvas = Image.new("RGBA", (s, s), (0, 0, 0, 0))

    if with_background:
        # Single solid bg with rounded corners — feels modern and confident
        bg = Image.new("RGBA", (s, s), (*BG_SOLID, 255))
        radius = int(s * 0.22)
        mask = rounded_mask(s, radius)
        clean = Image.new("RGBA", (s, s), (0, 0, 0, 0))
        clean.paste(bg, (0, 0), mask)
        canvas = clean

    # Geometry
    cx, cy = s // 2, int(s * 0.54)
    face_r = int(s * 0.27)
    frame_w = int(s * 0.055)

    # ---------------- Drop shadow under clock body ----------------
    shadow = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sh_offset = int(s * 0.012)
    sh_r = face_r + frame_w
    sd.ellipse(
        (cx - sh_r, cy - sh_r + sh_offset,
         cx + sh_r, cy + sh_r + sh_offset),
        fill=(0, 0, 0, 110),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=int(s * 0.025)))
    canvas = Image.alpha_composite(canvas, shadow)

    # ---------------- Legs (drawn before frame so frame overlaps tops) ----------------
    leg_w = int(s * 0.038)
    leg_len = int(s * 0.10)
    leg_top_y = cy + face_r - int(s * 0.005)
    leg_offset = int(face_r * 0.55)
    # Each leg: slanted thick line + round foot
    legs_layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    legs_mask = Image.new("L", (s, s), 0)
    lm = ImageDraw.Draw(legs_mask)
    foot_r = int(leg_w * 0.65)
    slant = int(s * 0.055)
    for sign in (-1, 1):
        top_x = cx + sign * leg_offset
        bot_x = top_x + sign * slant
        bot_y = leg_top_y + leg_len
        lm.line([(top_x, leg_top_y), (bot_x, bot_y)],
                fill=255, width=leg_w)
        # round foot
        lm.ellipse((bot_x - foot_r, bot_y - foot_r,
                    bot_x + foot_r, bot_y + foot_r), fill=255)
    legs = gradient_fill(s, legs_mask, PRIMARY_START, PRIMARY_END)
    canvas = Image.alpha_composite(canvas, legs)

    # ---------------- Bells ----------------
    bell_w = int(s * 0.18)
    bell_h = int(s * 0.16)
    bell_offset_x = int(s * 0.20)
    bell_cy = cy - face_r - int(s * 0.05)  # lift bells clearly above body
    bell_tilt = math.radians(8)  # subtle outward tilt
    bell_specs = [
        (cx - bell_offset_x, bell_cy, -bell_tilt),
        (cx + bell_offset_x, bell_cy, +bell_tilt),
    ]
    bell_mask = Image.new("L", (s, s), 0)
    bm = ImageDraw.Draw(bell_mask)
    for bcx, bcy, tilt in bell_specs:
        bm.polygon(bell_polygon(bcx, bcy, bell_w, bell_h, tilt), fill=255)
    bells = gradient_fill(s, bell_mask, PRIMARY_START, PRIMARY_END)
    # subtle highlight on each bell (top-left)
    bells_hl = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    bhd = ImageDraw.Draw(bells_hl)
    for bcx, bcy, tilt in bell_specs:
        hl_off = rotate_about(
            (bcx - bell_w * 0.18, bcy - bell_h * 0.10),
            (bcx, bcy), tilt,
        )
        hl_r = bell_w * 0.22
        bhd.ellipse(
            (hl_off[0] - hl_r, hl_off[1] - hl_r * 1.4,
             hl_off[0] + hl_r, hl_off[1] + hl_r * 1.4),
            fill=(255, 255, 255, 70),
        )
    bells_hl = bells_hl.filter(ImageFilter.GaussianBlur(radius=s // 200))
    bells_hl_clipped = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    bells_hl_clipped.paste(bells_hl, (0, 0), bell_mask)
    bells = Image.alpha_composite(bells, bells_hl_clipped)

    # ---------------- Hammer arc connecting bells ----------------
    hammer_w = int(s * 0.034)
    arc_r = int(s * 0.18)
    arc_cy = bell_cy + int(s * 0.02)
    hammer_mask = mask_from_draw(
        s,
        lambda d: d.arc(
            (cx - arc_r, arc_cy - arc_r, cx + arc_r, arc_cy + arc_r),
            start=200, end=340, fill=255, width=hammer_w,
        ),
    )
    hammer = gradient_fill(s, hammer_mask, PRIMARY_START, PRIMARY_END)
    canvas = Image.alpha_composite(canvas, hammer)
    canvas = Image.alpha_composite(canvas, bells)

    # ---------------- Clock face (solid white disk) ----------------
    face_layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    fd = ImageDraw.Draw(face_layer)
    fd.ellipse(
        (cx - face_r, cy - face_r, cx + face_r, cy + face_r),
        fill=FACE_COLOR,
    )
    canvas = Image.alpha_composite(canvas, face_layer)

    # ---------------- Outer frame (gradient ring) ----------------
    frame_outer_r = face_r + frame_w // 2
    frame_mask = mask_from_draw(
        s,
        lambda d: d.ellipse(
            (cx - frame_outer_r, cy - frame_outer_r,
             cx + frame_outer_r, cy + frame_outer_r),
            outline=255, width=frame_w,
        ),
    )
    frame = gradient_fill(s, frame_mask, PRIMARY_START, PRIMARY_END)
    canvas = Image.alpha_composite(canvas, frame)

    # ---------------- Hour markers ----------------
    # 12/3/6/9 → bold rounded bars; the other 8 → small dots
    mk_layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    md = ImageDraw.Draw(mk_layer)
    for i in range(12):
        ang = math.radians(-90 + i * 30)
        if i % 3 == 0:
            # major bar
            outer_r = face_r - int(s * 0.025)
            inner_r = outer_r - int(s * 0.055)
            x1 = cx + outer_r * math.cos(ang)
            y1 = cy + outer_r * math.sin(ang)
            x2 = cx + inner_r * math.cos(ang)
            y2 = cy + inner_r * math.sin(ang)
            bw = max(4, int(s * 0.018))
            md.line([(x1, y1), (x2, y2)], fill=DIAL_DARK, width=bw)
            # rounded caps
            r = bw / 2
            md.ellipse((x1 - r, y1 - r, x1 + r, y1 + r), fill=DIAL_DARK)
            md.ellipse((x2 - r, y2 - r, x2 + r, y2 + r), fill=DIAL_DARK)
        else:
            dot_r = int(s * 0.0085)
            cr = face_r - int(s * 0.045)
            x = cx + cr * math.cos(ang)
            y = cy + cr * math.sin(ang)
            md.ellipse((x - dot_r, y - dot_r, x + dot_r, y + dot_r),
                       fill=DIAL_DARK_SOFT)
    canvas = Image.alpha_composite(canvas, mk_layer)

    # ---------------- Hands at 10:10 ----------------
    hand_layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    hd = ImageDraw.Draw(hand_layer)
    # Hour hand: shorter, wider
    hour_pts = diamond_hand_polygon(
        cx, cy, angle_deg_from_12=10 * 30 + 10 * 0.5,
        length=face_r * 0.55, base_w=int(s * 0.028), tip_w=int(s * 0.010),
    )
    hd.polygon(hour_pts, fill=DIAL_DARK)
    # Minute hand: longer, slimmer
    min_pts = diamond_hand_polygon(
        cx, cy, angle_deg_from_12=10 * 6,
        length=face_r * 0.78, base_w=int(s * 0.022), tip_w=int(s * 0.008),
    )
    hd.polygon(min_pts, fill=DIAL_DARK)
    canvas = Image.alpha_composite(canvas, hand_layer)

    # ---------------- Center pivot ----------------
    pivot = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    pd = ImageDraw.Draw(pivot)
    p_outer = int(s * 0.026)
    p_mid = int(s * 0.020)
    p_inner = int(s * 0.009)
    pd.ellipse((cx - p_outer, cy - p_outer, cx + p_outer, cy + p_outer),
               fill=DIAL_DARK)
    pd.ellipse((cx - p_mid, cy - p_mid, cx + p_mid, cy + p_mid),
               fill=ACCENT_DOT)
    pd.ellipse((cx - p_inner, cy - p_inner, cx + p_inner, cy + p_inner),
               fill=(255, 250, 230, 255))
    canvas = Image.alpha_composite(canvas, pivot)

    return canvas


def render(size, with_background=True):
    big = build_foreground(BIG, with_background=with_background)
    return big.resize((size, size), Image.LANCZOS)


def main():
    print("Rendering master 1024 with background...")
    master = render(1024, with_background=True)
    master.save(OUT / "icon.png", "PNG")

    print("Rendering Play Store 512...")
    play = master.resize((512, 512), Image.LANCZOS)
    play.save(OUT / "playstore_512.png", "PNG")

    print("Rendering adaptive foreground (transparent bg) 1024...")
    fg = render(1024, with_background=False)
    fg.save(OUT / "icon_foreground.png", "PNG")

    # ----- Android mipmap launcher icons -----
    android_res = ROOT / "android" / "app" / "src" / "main" / "res"
    mipmap_sizes = {
        "mipmap-mdpi": 48, "mipmap-hdpi": 72, "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144, "mipmap-xxxhdpi": 192,
    }
    print("Writing Android mipmap launcher icons...")
    for folder, sz in mipmap_sizes.items():
        d = android_res / folder
        d.mkdir(parents=True, exist_ok=True)
        master.resize((sz, sz), Image.LANCZOS).save(d / "ic_launcher.png", "PNG")

    print("Writing adaptive icon foregrounds...")
    adaptive_sizes = {
        "mipmap-mdpi": 108, "mipmap-hdpi": 162, "mipmap-xhdpi": 216,
        "mipmap-xxhdpi": 324, "mipmap-xxxhdpi": 432,
    }
    # Tighten the foreground so the clock fills the 66dp safe-zone of the
    # 108dp adaptive canvas. Master art has clock spanning ~77% of canvas
    # height; an inner-ratio of 0.80 puts the clock right at the safe-zone
    # edge — matches how Material Design system icons size themselves.
    INNER_RATIO = 0.80
    for folder, sz in adaptive_sizes.items():
        canvas = Image.new("RGBA", (sz, sz), (0, 0, 0, 0))
        inner = int(sz * INNER_RATIO)
        art = fg.resize((inner, inner), Image.LANCZOS)
        offset = (sz - inner) // 2
        canvas.paste(art, (offset, offset), art)
        canvas.save(android_res / folder / "ic_launcher_foreground.png", "PNG")

    # ----- iOS AppIcon set -----
    ios_set = (
        ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    )
    if ios_set.exists():
        print("Writing iOS AppIcon set...")
        ios_icons = [
            ("Icon-App-20x20@1x.png", 20),
            ("Icon-App-20x20@2x.png", 40),
            ("Icon-App-20x20@3x.png", 60),
            ("Icon-App-29x29@1x.png", 29),
            ("Icon-App-29x29@2x.png", 58),
            ("Icon-App-29x29@3x.png", 87),
            ("Icon-App-40x40@1x.png", 40),
            ("Icon-App-40x40@2x.png", 80),
            ("Icon-App-40x40@3x.png", 120),
            ("Icon-App-60x60@2x.png", 120),
            ("Icon-App-60x60@3x.png", 180),
            ("Icon-App-76x76@1x.png", 76),
            ("Icon-App-76x76@2x.png", 152),
            ("Icon-App-83.5x83.5@2x.png", 167),
            ("Icon-App-1024x1024@1x.png", 1024),
        ]
        flat_master = Image.new("RGB", master.size, BG_SOLID)
        flat_master.paste(master, (0, 0),
                          master.split()[3] if master.mode == "RGBA" else None)
        for name, sz in ios_icons:
            flat_master.resize((sz, sz), Image.LANCZOS).save(ios_set / name, "PNG")

    print("All icons written.")


if __name__ == "__main__":
    main()
