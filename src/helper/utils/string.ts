export function capitalize(input: string): string{
  return input
    .split(/_+/)
    .map((s: string) => `${s[0].toUpperCase()}${s.substring(1).toLowerCase()}`)
    .join(' ');
}
