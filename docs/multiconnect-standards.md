# Multiconnect Development Standards

## Backer Standards

- Back types as a single module accepting height and width parameters
- All customizable parameters for a back type must be enclosed in their own parameter section
- All backs must have parameterized spacing to accommodate various mounting surfaces (e.g., 25mm for Multiboard and 28mm for openGrid)

## Positioning Standards

- Model starts at X 0 and goes positive
- Back starts at X 0 and goes negative
- Center the entire unit on x axis last

## Testing Criteria

- Compiles without error
- Test items under 5mm in height, depth, and width and verify back generates properly
- Test for very large items
