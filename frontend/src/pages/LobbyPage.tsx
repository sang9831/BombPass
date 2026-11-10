import { Link } from 'react-router-dom';
export function LobbyPage() { return <section><h1>폭탄을 넘겨라!</h1><p>실시간 멀티플레이 게임 BOMB PASS</p><Link to="/login">로그인으로 이동</Link><p className="muted">방 생성/참여는 추후 구현</p></section>; }
