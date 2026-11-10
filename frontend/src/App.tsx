import { Link, Route, Routes } from 'react-router-dom';
import { LoginPage } from './pages/LoginPage';
import { LobbyPage } from './pages/LobbyPage';
import { RoomPage } from './pages/RoomPage';
import { GamePage } from './pages/GamePage';
export default function App() {
  return <main><header><Link to="/">💣 BOMB PASS</Link><span>Realtime multiplayer starter</span></header><Routes>
    <Route path="/" element={<LobbyPage />} />
    <Route path="/login" element={<LoginPage />} />
    <Route path="/rooms/:roomId" element={<RoomPage />} />
    <Route path="/games/:roomId" element={<GamePage />} />
  </Routes></main>;
}
