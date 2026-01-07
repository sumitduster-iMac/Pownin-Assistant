# UI Design Documentation

## Design System

### Color Palette

| Purpose | Light Mode | Dark Mode |
|---------|------------|-----------|
| Primary Background | #FFFFFF | #1A1A2E |
| Secondary Background | #F5F5F5 | #16213E |
| Accent | #007AFF | #E94560 |
| Text Primary | #000000 | #FFFFFF |
| Text Secondary | #666666 | #A0A0A0 |

### Typography

- **Headings**: SF Pro Display, Bold
- **Body**: SF Pro Text, Regular
- **Code**: SF Mono, Regular

### Spacing

- Base unit: 4px
- Common spacings: 8px, 12px, 16px, 20px, 24px

## Components

### Chat Bubbles
- User messages: Accent color with rounded corners
- AI messages: Secondary background with AI avatar

### Status Indicators
- Active: Green pulse animation
- Processing: Orange spinner
- Error: Red static

## Responsive Behavior

- Minimum window: 600x400
- Sidebar collapses on narrow windows
- Chat area remains scrollable
