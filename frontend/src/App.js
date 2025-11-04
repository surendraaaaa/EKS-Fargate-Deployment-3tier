import React, { useEffect, useState } from 'react';

function App() {
  const [messages, setMessages] = useState([]);

  useEffect(() => {
    fetch(process.env.REACT_APP_API_URL || '/api/messages')
      .then(res => res.json())
      .then(data => setMessages(data))
      .catch(err => console.error(err));
  }, []);

  return (
    <div style={{ padding: "2rem", fontFamily: "sans-serif" }}>
      <h1>🌐 3-Tier Web App</h1>
      <p>Frontend ➡️ Backend ➡️ Database</p>
      <h3>Messages from DB:</h3>
      <ul>
        {messages.map(m => (
          <li key={m.id}>{m.content} — {m.created_at}</li>
        ))}
      </ul>
    </div>
  );
}

export default App;
