# Pandangan Pribadi tentang Animasi dalam Aplikasi Mobile

Menurut saya animasi dalam aplikasi bukan hanya elemen dekoratif, melainkan komponen fungsional yang vital. Animasi berperan sebagai jembatan komunikasi antara sistem dan pengguna.
Animasi ini bisa menjadi media komunikasi kita dengan user, karena animasi memberikan feedback instan dan konteks yang jelas, sehingga mengurangi beban kognitif pengguna.
Kemudian, Animasi mampu memanipulasi persepsi waktu, membuat waktu tunggu terasa lebih singkat dan aplikasi terasa lebih responsif.
Juga, dengan menggunakan animasi kustom, kita dapat membangun hubungan emosional dan identitas brand yang kuat dibandingkan elemen standar.

## Lampiran: Alur Animasi dan Implementasi Teknis

### Animation Flow States

1. **App Launch**
   - Page Fade In (800ms)
   - Form Slide In (600ms)
   - Button Scale In (400ms)
   - Mascot Idle (continuous)

2. **User Types Email**
   - Mascot State: typing
   - Email Field Glow (blue)

3. **User Types Password**
   - Mascot State: coveringEyes
   - Password Field Glow (purple)
   - Mascot Cover Animation (300ms)

4. **User Clicks Sign In**
   - Mascot State: loading
   - Background Color: orange
   - Button: SpinKitThreeBounce
   - Mascot: Rotating Hourglass

5. **Login Success**
   - Mascot State: success
   - Background Color: green (300ms)
   - Mascot: Stars Animation (500ms)
   - Wait 1500ms
   - Navigate to Home

6. **Login Failed**
   - Mascot State: failed
   - Background Color: red (300ms)
   - Mascot: X Eyes Animation (500ms)
   - Show SnackBar
   - Wait 2000ms
   - Reset to Idle

### Widget Animation Implementations

#### 1. AnimatedContainer
- Background gradient transitions
- Mascot size and color changes
- Text field shadow effects

#### 2. AnimationController
- Mascot idle floating
- Mascot blinking
- Mascot bounce on success/fail
- Page fade in
- Form slide in
- Button scale

#### 3. CurvedAnimation
- All controllers use curves for natural motion
- easeIn, easeOut, elasticOut, easeInOut

#### 4. FadeTransition
- Page entrance animation

#### 5. SlideTransition
- Form fields entrance
- Mascot floating motion

#### 6. ScaleTransition
- Button scale animation
- Mascot bounce animation

#### 7. TweenAnimationBuilder
- Email field entrance
- Password field entrance
- Mascot state transitions

#### 8. Hero
- Mascot transition between pages

#### 9. CustomPainter
- Smile path for success state
- Frown path for failed state