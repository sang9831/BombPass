import { useParams } from 'react-router-dom';
export function GamePage() { const { roomId } = useParams(); return <section><h1>게임 진행</h1><p>방 ID: {roomId}</p><p>폭탄 전달과 타이머는 Redis 원자적 처리 구현 후 연결</p></section>; }
