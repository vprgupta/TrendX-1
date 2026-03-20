import mongoose, { Document, Schema } from 'mongoose';

export interface IChatMessage extends Document {
    trendId: string;
    text: string;
    senderName: string;
    timestamp: Date;
}

const ChatMessageSchema: Schema = new Schema({
    trendId: {
        type: String,
        required: true,
        index: true,
    },
    text: {
        type: String,
        required: true,
        trim: true,
        maxlength: 1000,
    },
    senderName: {
        type: String,
        required: true,
        trim: true,
        maxlength: 50,
    },
    timestamp: {
        type: Date,
        default: Date.now,
        index: true,
    },
});

export default mongoose.model<IChatMessage>('ChatMessage', ChatMessageSchema);
