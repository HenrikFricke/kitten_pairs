// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Alegreya Sans', ...defaultTheme.fontFamily.sans],
      },
      keyframes: {
        'gentle-pulse': {
          '0%, 100%': { transform: 'scale(1)' },
          '50%': { transform: 'scale(0.98)' },
        }
      },
      animation: {
        'gentle-pulse': 'gentle-pulse 700ms ease-in-out infinite',
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms')
  ]
}
