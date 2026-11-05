TIGER X ANDROID STARTER — आसान हिंदी गाइड

इस ZIP में:
- app/: Flutter Android app source code
- backend/: Gemini AI से जवाब देने वाला Python API
- .github/workflows/: GitHub पर APK build करने की workflow

यह शुरुआती SOURCE CODE है, तैयार APK नहीं।
AI chat के लिए backend को internet पर deploy करना होगा।
Gemini API key को app code में न डालें और chat में किसी को न भेजें।
Backend hosting पर GEMINI_API_KEY नाम का secret/environment variable बनाएं।
फिर app/lib/main.dart में backendUrl को अपने deployed HTTPS URL से बदलें।

मोबाइल से APK बनाने के चरण:
1. GitHub account में login करें और नया repository बनाएं, जैसे tiger-x.
2. ZIP extract करके अंदर की सभी files GitHub repository में upload करें।
   ध्यान दें: .github folder भी upload होना चाहिए।
3. Files को main branch में commit करें।
4. Repository का Actions tab खोलें।
5. "Build TIGER X Android APK" workflow चुनें और Run workflow दबाएं।
6. Build पूरा होने पर workflow run खोलें।
7. Artifacts में TIGER-X-Android-APK डाउनलोड करें।
8. ZIP खोलकर app-release.apk निकालें और Android फोन में install करें।

Backend deploy:
- backend folder को FastAPI/ASGI support वाली Python hosting पर deploy करें।
- Start command: uvicorn main:app --host 0.0.0.0 --port $PORT
- Environment variable: GEMINI_API_KEY = आपकी Gemini API key
- Deploy के बाद HTTPS URL मिलेगा। उसे main.dart के backendUrl में लगाएं और APK फिर build करें।

अभी इसमें advanced pronunciation scoring, login, saved lessons, streaks और live Google Search नहीं हैं।
Speech recognition Android device की language support पर निर्भर है; Odia हर फोन पर उपलब्ध हो, यह जरूरी नहीं।
API key को APK में रखना सुरक्षित नहीं है; उसे केवल backend secret में रखें।
